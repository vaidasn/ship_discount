# frozen_string_literal: true

require 'ship_discount'
require 'ship_discount/discount_processor'

RSpec.describe ShipDiscount do
  it 'has a version number' do
    expect(ShipDiscount::VERSION).not_to be nil
  end
  it 'invokes DiscountProcessor from process' do
    discount_processor = double('DiscountProcessor')
    expect(discount_processor).to receive(:process).with(no_args)
    expect(ShipDiscount::DiscountProcessor).to receive(:new)
      .with('input_test.txt', $stderr).and_return discount_processor
    ShipDiscount.process 'input_test.txt', $stderr
  end
end
