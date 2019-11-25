# frozen_string_literal: true

require 'ship_discount/providers'
require 'date'

module ShipDiscount
  module Transaction
    DATE = 0
    PACKAGE_SIZE = 1
    PROVIDER = 2
    PRICE = 3
    DISCOUNT = 4
  end
  # Converts input fields into transaction
  class TransactionConverter
    include Transaction
    # Creates new transaction converter
    # @param [ShipDiscount::Providers] providers providers for price calculation
    # @throw
    # :invalid_transaction in case of transaction validation of parse error
    def initialize(providers)
      @last_transaction = nil
      @providers = providers
    end

    # @param [Array] fields
    # @return [Array] transaction fields from DATE to PRICE
    def next_transaction(fields)
      throw :invalid_transaction if fields.length != 3
      transaction = read_transaction fields
      previous_transaction = @last_transaction
      @last_transaction = transaction
      validate_transaction previous_transaction, transaction
      transaction
    end

    private

    def read_transaction(fields)
      transaction = []
      transaction[DATE] = Date.parse(fields[0])
      transaction[PACKAGE_SIZE] = fields[1]
      transaction[PROVIDER] = fields[2]
      transaction[PRICE] = calc_price transaction
      transaction.dup
    rescue ArgumentError
      throw :invalid_transaction
    end

    def calc_price(transaction)
      provider = @providers[transaction[PROVIDER]]
      throw :invalid_transaction unless provider
      package = provider.packages[transaction[PACKAGE_SIZE]]
      throw :invalid_transaction unless package
      package.price
    end

    def validate_transaction(previous_transaction, transaction)
      unless previous_transaction &&
             transaction[DATE] < previous_transaction[DATE]
        return
      end

      throw :invalid_transaction
    end
  end
end
