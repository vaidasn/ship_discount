# frozen_string_literal: true

require 'shipdiscount/providers'
require 'shipdiscount/transaction'
require 'bigdecimal'

module Shipdiscount
  # Rule: Accumulated discounts cannot exceed 10 EUR in a calendar month.
  # If there are not enough funds to fully cover a discount this calendar month,
  # it should be covered partially
  class AccumulatedDiscountsLimitRule
    # Creates new rule
    def initialize(_providers)
      @last_date = nil
      @accumulated_discount = BigDecimal('0.0')
    end

    def apply(transaction)
      discount = transaction[Shipdiscount::Transaction::DISCOUNT]
      return unless discount

      try_reset_accumulated_discount transaction
      @accumulated_discount += discount
      if @accumulated_discount > BigDecimal('10.0')
        transaction[Shipdiscount::Transaction::DISCOUNT] =
          (discount - @accumulated_discount + BigDecimal('10.0')).to_f
      end
      try_delete_exceeded_discount transaction
    end

    private

    def try_reset_accumulated_discount(transaction)
      transaction_date = transaction[Shipdiscount::Transaction::DATE]
      if @last_date &&
         (@last_date.year != transaction_date.year ||
             @last_date.month != transaction_date.month)
        @accumulated_discount = BigDecimal('0.0')
      end
      @last_date = transaction_date
    end

    def try_delete_exceeded_discount(transaction)
      if transaction[Shipdiscount::Transaction::DISCOUNT] > BigDecimal('0.0')
        return
      end

      transaction.delete_at Shipdiscount::Transaction::DISCOUNT
    end
  end
end
