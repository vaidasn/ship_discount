# frozen_string_literal: true

require 'date'
require 'shipdiscount/rules'
require 'shipdiscount/rules/small_shipment_rule'
require 'shipdiscount/rules/third_large_shipment_via_lp_rule'

RSpec.describe 'All and specific Rules' do
  context Shipdiscount::Rules do
    let(:providers) do
      double('Providers')
    end
    let(:small_size_rule) { double('SmallSizeRule', apply: nil) }
    subject do
      expect(Shipdiscount::SmallShipmentRule).to receive(:new)
        .with(providers).and_return(small_size_rule)
      Shipdiscount::Rules.new(providers)
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

  context Shipdiscount::SmallShipmentRule do
    Package = Struct.new(:size, :price)
    let(:providers) do
      provider1 = double('Provider1')
      expect(provider1).to receive(:packages)
        .and_return('S' => Package.new('S', 2.0),
                    'M' => Package.new('M', 4.0))
      provider2 = double('Provider2')
      expect(provider2).to receive(:packages)
        .and_return('S' => Package.new('S', 1.0))
      provider3 = double('Provider3')
      expect(provider3).to receive(:packages)
        .and_return('S' => Package.new('S', 3.0),
                    'L' => Package.new('L', 5.0))
      providers = double('Providers')
      expect(providers).to receive(:each)
        .and_yield(provider1).and_yield(provider2).and_yield(provider3)
      providers
    end
    subject do
      # noinspection RubyYardParamTypeMatch
      Shipdiscount::SmallShipmentRule.new(providers)
    end
    it 'should not apply a discount for lowest price' do
      apply_transaction [Date.parse('2015-02-01'), 'S', 'MR', 1.0], [1.0]
    end
    it 'should apply a discount for higher price' do
      apply_transaction [Date.parse('2015-02-13'), 'S', 'LP', 2.0], [2.0, 1.0]
    end
  end

  context Shipdiscount::ThirdLargeShipmentViaLpRule do
    subject do
      Shipdiscount::ThirdLargeShipmentViaLpRule.new(nil)
    end
    it 'should not apply a discount first' do
      apply_transaction [Date.parse('2015-02-03'), 'L', 'LP', 5.0], [5.0]
    end
    it 'should apply discount on third L LP' do
      apply_transaction [Date.parse('2015-02-01'), 'S', 'MR', 2.0], [2.0]
      apply_transaction [Date.parse('2015-02-03'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [Date.parse('2015-02-05'), 'S', 'LP', 1.5], [1.5]
      apply_transaction [Date.parse('2015-02-06'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [Date.parse('2015-02-09'), 'L', 'LP', 6.9], [0.0, 6.9]
      apply_transaction [Date.parse('2015-02-10'), 'L', 'LP', 6.9], [6.9]
    end
    it 'should reset L LP counter on month change' do
      apply_transaction [Date.parse('2015-02-01'), 'S', 'MR', 2.0], [2.0]
      apply_transaction [Date.parse('2015-02-03'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [Date.parse('2015-03-05'), 'S', 'LP', 1.5], [1.5]
      apply_transaction [Date.parse('2015-03-06'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [Date.parse('2015-03-09'), 'L', 'LP', 6.9], [6.9]
      apply_transaction [Date.parse('2015-03-10'), 'L', 'LP', 6.9], [0.0, 6.9]
    end
  end
end
