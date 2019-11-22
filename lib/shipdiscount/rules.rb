# frozen_string_literal: true

require 'shipdiscount/rules/small_shipment_rule'
module Shipdiscount
  # Shipment Discount Calculation rules that should
  # be applied on a transaction
  class Rules
    # Creates new rules
    def initialize(providers)
      rules = []
      rules << Shipdiscount::SmallShipmentRule.new(providers)
      @rules = rules.freeze
    end

    def apply(transaction)
      @rules.each { |rule| rule.apply(transaction) }
    end
  end
end
