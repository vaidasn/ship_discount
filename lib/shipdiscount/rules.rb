# frozen_string_literal: true

require 'shipdiscount/rules/small_shipment_rule'
require 'shipdiscount/rules/third_large_shipment_via_lp_rule'
require 'shipdiscount/rules/accumulated_discounts_limit_rule'

module Shipdiscount
  # Shipment Discount Calculation rules that should
  # be applied on a transaction
  class Rules
    # Creates new rules
    def initialize(providers)
      @rules =
        [Shipdiscount::SmallShipmentRule,
         Shipdiscount::ThirdLargeShipmentViaLpRule,
         Shipdiscount::AccumulatedDiscountsLimitRule].map do |r|
          r.new(providers)
        end.freeze
    end

    def apply(transaction)
      @rules.each { |rule| rule.apply(transaction) }
    end
  end
end
