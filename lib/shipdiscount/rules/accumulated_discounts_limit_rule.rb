# frozen_string_literal: true

require 'shipdiscount/providers'
require 'bigdecimal'

module Shipdiscount
  # Rule: Accumulated discounts cannot exceed 10 € in a calendar month.
  # If there are not enough funds to fully cover a discount this calendar month,
  # it should be covered partially
  class AccumulatedDiscountsLimitRule
    # Creates new rule
    def initialize(_providers)
      @last_date = nil
      @accumulated_discount = BigDecimal('0.0')
    end

    def apply(transaction)
      discount = transaction[4]
      return unless discount

      try_reset_accumulated_discount transaction
      @accumulated_discount += discount
      if @accumulated_discount > BigDecimal('10.0')
        transaction[4] = (discount - @accumulated_discount + BigDecimal('10.0')).to_f
      end
      transaction.delete_at 4 if transaction[4] <= BigDecimal('0.0')
    end

    private

    def try_reset_accumulated_discount(transaction)
      transaction_date = transaction[0]
      if @last_date &&
         (@last_date.year != transaction_date.year ||
             @last_date.month != transaction_date.month)
        @accumulated_discount = BigDecimal('0.0')
      end
      @last_date = transaction_date
    end
  end
end
