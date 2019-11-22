# frozen_string_literal: true

require 'date'
require 'shipdiscount/rules'
require 'shipdiscount/rules/small_size_rule'

RSpec.describe 'All and specific Rules' do
  context Shipdiscount::Rules do
    let(:providers) do
      double('Providers')
    end
    let(:small_size_rule) { double('SmallSizeRule', apply: nil) }
    subject do
      expect(Shipdiscount::SmallSizeRule).to receive(:new)
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

  context Shipdiscount::SmallSizeRule do
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
      Shipdiscount::SmallSizeRule.new(providers)
    end
    it 'should not apply a discount for lowest price' do
      transaction = [Date.parse('2015-02-01'), 'S', 'MR', 1.0]
      subject.apply(transaction)
      expect(transaction).to eq [Date.parse('2015-02-01'), 'S', 'MR', 1.0]
    end
    it 'should apply a discount for higher price' do
      transaction = [Date.parse('2015-02-13'), 'S', 'LP', 2.0]
      subject.apply(transaction)
      expect(transaction).to eq [Date.parse('2015-02-13'), 'S', 'LP', 2.0, 1.0]
    end
  end
end
