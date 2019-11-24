# frozen_string_literal: true

require 'shipdiscount/discount_processor'

# Shipment discount calculation module
module Shipdiscount
  def self.process(in_file, out_fd)
    DiscountProcessor.new(in_file, out_fd).process
  end
end
