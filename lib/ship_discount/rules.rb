# frozen_string_literal: true

require 'ship_discount/rules/small_shipment_rule'
require 'ship_discount/rules/third_large_shipment_via_lp_rule'
require 'ship_discount/rules/accumulated_discounts_limit_rule'

module ShipDiscount
  # Shipment Discount Calculation rules that should
  # be applied on a transaction
  class Rules
    # Creates new rules
    def initialize(providers)
      @rules =
        [SmallShipmentRule,
         ThirdLargeShipmentViaLpRule,
         AccumulatedDiscountsLimitRule].map { |r| r.new(providers) }.freeze
    end

    def apply(transaction)
      @rules.each { |rule| rule.apply(transaction) }
    end
  end
end
