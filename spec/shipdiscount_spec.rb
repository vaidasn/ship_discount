# frozen_string_literal: true

require 'shipdiscount'
require 'shipdiscount/discount_processor'

RSpec.describe Shipdiscount do
  it 'has a version number' do
    expect(Shipdiscount::VERSION).not_to be nil
  end
  it 'invokes DiscountProcessor from process' do
    discount_processor = double('DiscountProcessor')
    expect(discount_processor).to receive(:process).with(no_args)
    expect(Shipdiscount::DiscountProcessor).to receive(:new)
      .with('input_test.txt', $stderr).and_return discount_processor
    Shipdiscount.process 'input_test.txt', $stderr
  end
end
