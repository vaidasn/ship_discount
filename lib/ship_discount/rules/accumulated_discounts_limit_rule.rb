# frozen_string_literal: true

require 'ship_discount/transaction_converter'
require 'bigdecimal'

module ShipDiscount
  # Rule: Accumulated discounts cannot exceed 10 EUR in a calendar month.
  # If there are not enough funds to fully cover a discount this calendar month,
  # it should be covered partially
  class AccumulatedDiscountsLimitRule
    include Transaction
    # Creates new rule
    def initialize(_providers)
      @last_date = nil
      @accumulated_discount = ZERO
    end

    def apply(transaction)
      discount = transaction[DISCOUNT]
      return unless discount

      try_reset_accumulated_discount transaction
      @accumulated_discount += discount
      return unless @accumulated_discount > TEN

      transaction[DISCOUNT] = (discount - @accumulated_discount + TEN).to_f
      try_delete_exceeded_discount transaction
      limited_discount = transaction[DISCOUNT]
      transaction[PRICE] +=
        limited_discount ? discount - limited_discount : discount
    end

    private

    ZERO = BigDecimal('0.0')
    TEN = BigDecimal('10.0')

    private_constant :ZERO, :TEN

    def try_reset_accumulated_discount(transaction)
      transaction_date = transaction[DATE]
      if @last_date &&
         (@last_date.year != transaction_date.year ||
             @last_date.month != transaction_date.month)
        @accumulated_discount = ZERO
      end
      @last_date = transaction_date
    end

    def try_delete_exceeded_discount(transaction)
      return if transaction[DISCOUNT] > ZERO

      transaction.delete_at DISCOUNT
    end
  end
end
