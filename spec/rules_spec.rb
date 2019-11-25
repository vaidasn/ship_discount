# frozen_string_literal: true

require 'date'
require 'ship_discount/rules'
require 'ship_discount/rules/small_shipment_rule'
require 'ship_discount/rules/third_large_shipment_via_lp_rule'
require 'ship_discount/rules/accumulated_discounts_limit_rule'

RSpec.describe 'All and specific Rules' do
  context ShipDiscount::Rules do
    let(:providers) do
      double('Providers')
    end
    let(:small_size_rule) do
      double('SmallSizeRule', apply: nil)
    end
    let(:third_large_shipment_via_lp_rule) do
      double('ThirdLargeShipmentViaLpRule', apply: nil)
    end
    let(:accumulated_discounts_limit_rule) do
      double('AccumulatedDiscountsLimitRule', apply: nil)
    end
    subject do
      expect(ShipDiscount::SmallShipmentRule).to receive(:new)
        .with(providers).and_return(small_size_rule)
      expect(ShipDiscount::ThirdLargeShipmentViaLpRule).to receive(:new)
        .with(providers).and_return(third_large_shipment_via_lp_rule)
      expect(ShipDiscount::AccumulatedDiscountsLimitRule).to receive(:new)
        .with(providers).and_return(accumulated_discounts_limit_rule)
      ShipDiscount::Rules.new(providers)
    end
    it 'covers all rules' do
      expect(subject.instance_variable_get(:@rules)).to all be_a(double.class)
    end
    it 'applies all rules' do
      transaction = double('Transaction')
      expect(small_size_rule).to receive(:apply).with(transaction)
      subject.apply(transaction)
    end
  end

  def apply_transaction(in_transaction, price_and_discount)
    transaction = in_transaction.dup
    subject.apply(transaction)
    expected = in_transaction.dup
    expected[3..4] = price_and_discount
    expect(transaction).to eq expected
  end

  context ShipDiscount::SmallShipmentRule do
    PackageForRule = Struct.new(:size, :price)
    let(:providers) do
      provider1 = double('Provider1')
      expect(provider1).to receive(:packages)
        .and_return('S' => PackageForRule.new('S', 2.0),
                    'M' => PackageForRule.new('M', 4.0))
      provider2 = double('Provider2')
      expect(provider2).to receive(:packages)
        .and_return('S' => PackageForRule.new('S', 1.0))
      provider3 = double('Provider3')
      expect(provider3).to receive(:packages)
        .and_return('S' => PackageForRule.new('S', 3.0),
                    'L' => PackageForRule.new('L', 5.0))
      providers = double('Providers')
      expect(providers).to receive(:each)
        .and_yield(provider1).and_yield(provider2).and_yield(provider3)
      providers
    end
    subject do
      # noinspection RubyYardParamTypeMatch
      ShipDiscount::SmallShipmentRule.new(providers)
    end
    it 'should not apply a discount for lowest price' do
      apply_transaction [ymd('2015-02-01'), 'S', 'MR', 1.0], [1.0]
    end
    it 'should apply a discount for higher price' do
      apply_transaction [ymd('2015-02-13'), 'S', 'LP', 2.0], [1.0, 1.0]
    end
  end

  context ShipDiscount::ThirdLargeShipmentViaLpRule do
    subject do
      ShipDiscount::ThirdLargeShipmentViaLpRule.new(nil)
    end
    it 'should not apply a discount first' do
      apply_transaction [ymd('2015-02-03'), 'L', 'LP', 5.0], [5.0]
    end
    it 'should apply discount on third L LP' do
      apply_transaction [ymd('2015-02-01'), 'S', 'MR', 2.0], [2.0]
      apply_transaction [ymd('2015-02-03'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [ymd('2015-02-05'), 'S', 'LP', 1.5], [1.5]
      apply_transaction [ymd('2015-02-06'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [ymd('2015-02-09'), 'L', 'LP', 6.9], [0.0, 6.9]
      apply_transaction [ymd('2015-02-10'), 'L', 'LP', 6.9], [6.9]
    end
    it 'should reset L LP counter on month change' do
      apply_transaction [ymd('2015-02-01'), 'S', 'MR', 2.0], [2.0]
      apply_transaction [ymd('2015-02-03'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [ymd('2015-03-05'), 'S', 'LP', 1.5], [1.5]
      apply_transaction [ymd('2015-03-06'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [ymd('2015-03-09'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [ymd('2015-03-10'), 'L', 'LP', 6.9], [0.0, 6.9]
    end
  end
  context ShipDiscount::AccumulatedDiscountsLimitRule do
    subject do
      ShipDiscount::AccumulatedDiscountsLimitRule.new(nil)
    end
    it 'should not exceed limit within one month' do
      apply_transaction [ymd('2015-02-01'), 'S', 'MR', 1.0, 1.0], [1.0, 1.0]
      apply_transaction [ymd('2015-02-03'), 'L', 'LP', 6.0], [6.0]
      apply_transaction [ymd('2015-02-05'), 'S', 'LP', 1.5], [1.5]
      apply_transaction [ymd('2015-02-09'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [ymd('2015-02-10'), 'L', 'LP', 0.0, 6.9], [0.0, 6.9]
      apply_transaction [ymd('2015-02-12'), 'S', 'MR', 1.0, 1.0], [1.0, 1.0]
      apply_transaction [ymd('2015-02-14'), 'S', 'MR', 1.0, 1.0], [1.0, 1.0]
      apply_transaction [ymd('2015-02-15'), 'S', 'MR', 1.0, 1.0], [1.9, 0.1]
      apply_transaction [ymd('2015-02-15'), 'S', 'MR', 1.0, 1.0], [2.0]
    end
    it 'should not exceed limit within one month' do
      apply_transaction [ymd('2015-02-01'), 'S', 'MR', 1.0, 1.0], [1.0, 1.0]
      apply_transaction [ymd('2015-02-03'), 'L', 'LP', 6.0], [6.0]
      apply_transaction [ymd('2015-02-05'), 'S', 'LP', 1.5], [1.5]
      apply_transaction [ymd('2015-03-09'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [ymd('2015-03-10'), 'L', 'LP', 0.0, 6.9], [0.0, 6.9]
      apply_transaction [ymd('2015-03-12'), 'S', 'MR', 1.0, 1.0], [1.0, 1.0]
      apply_transaction [ymd('2015-03-14'), 'S', 'MR', 1.0, 1.0], [1.0, 1.0]
      apply_transaction [ymd('2015-03-15'), 'S', 'MR', 1.0, 1.0], [1.0, 1.0]
      apply_transaction [ymd('2015-03-15'), 'S', 'MR', 1.0, 1.0], [1.9, 0.1]
    end
  end
end
