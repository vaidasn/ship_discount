# frozen_string_literal: true

require 'ship_discount/discount_processor'
require 'ship_discount/data_file'

RSpec.describe ShipDiscount::DiscountProcessor do
  subject do
    processor = ShipDiscount::DiscountProcessor.new 'input.txt', $stdout
    expect(ShipDiscount::DataFile).to receive(:each_record)
      .with('input.txt') do |&block|
      block.call %w[2015-02-01 S MR]
      block.call %w[2015-02-03 L LP]
      block.call %w[2015-02-06 L LP]
      block.call %w[2015-02-09 L LP]
      block.call %w[2015-02-29 CUSPS]
    end
    processor
  end
  it 'succeeds with integration test' do
    expect { subject.process }.to output(<<~END_OUTPUT).to_stdout
      2015-02-01 S MR 1.50 0.50
      2015-02-03 L LP 6.90 -
      2015-02-06 L LP 6.90 -
      2015-02-09 L LP 0.00 6.90
      2015-02-29 CUSPS Ignored
    END_OUTPUT
  end
end
