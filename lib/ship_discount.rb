# frozen_string_literal: true

require 'ship_discount/discount_processor'

# Shipment discount calculation module
module ShipDiscount
  def self.process(in_file, out_fd)
    DiscountProcessor.new(in_file, out_fd).process
  end
end
