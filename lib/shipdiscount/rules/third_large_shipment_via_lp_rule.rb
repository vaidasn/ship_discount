# frozen_string_literal: true

require 'shipdiscount/transaction_converter'

module Shipdiscount
  # Rule: Third L shipment via LP should be free,
  # but only once a calendar month
  class ThirdLargeShipmentViaLpRule
    include Transaction
    # Creates new rule
    def initialize(_providers)
      @last_date = nil
      @count_per_month = 0
    end

    def apply(transaction)
      if transaction[PACKAGE_SIZE] != 'L' ||
         transaction[PROVIDER].upcase != 'LP'
        return
      end

      count_transaction(transaction)
      return if @count_per_month != 3

      price = transaction[PRICE]
      transaction[PRICE] = 0.0
      transaction[DISCOUNT] = price
    end

    private

    def count_transaction(transaction)
      transaction_date = transaction[DATE]
      if @last_date &&
         (@last_date.year != transaction_date.year ||
             @last_date.month != transaction_date.month)
        @count_per_month = 0
      end
      @count_per_month += 1
      @last_date = transaction_date
    end
  end
end
