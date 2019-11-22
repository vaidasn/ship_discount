# frozen_string_literal: true

require 'shipdiscount/providers'

module Shipdiscount
  # Rule: Third L shipment via LP should be free,
  # but only once a calendar month
  class ThirdLargeShipmentViaLpRule
    # Creates new rule
    def initialize(_providers)
      @last_date = nil
      @count_per_month = 0
    end

    def apply(transaction)
      return if transaction[1] != 'L' || transaction[2].upcase != 'LP'

      count_transaction(transaction)
      return if @count_per_month != 3

      price = transaction[3]
      transaction[3] = 0.0
      transaction[4] = price
    end

    private

    def count_transaction(transaction)
      transaction_date = transaction[0]
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
