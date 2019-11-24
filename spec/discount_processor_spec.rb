# frozen_string_literal: true

require 'shipdiscount/discount_processor'
require 'shipdiscount/data_file'

RSpec.describe Shipdiscount::DiscountProcessor do
  subject do
    processor = Shipdiscount::DiscountProcessor.new 'input.txt', $stdout
    expect(Shipdiscount::DataFile).to receive(:each_record)
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
      2015-02-01 S MR 2.0 0.5
      2015-02-03 L LP 6.9
      2015-02-06 L LP 6.9
      2015-02-09 L LP 0.0 6.9
      2015-02-29 CUSPS Ignored
    END_OUTPUT
  end
end
