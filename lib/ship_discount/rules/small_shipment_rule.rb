# frozen_string_literal: true

require 'ship_discount/providers'
require 'ship_discount/transaction_converter'

module ShipDiscount
  # Rule: All S shipments should always match the lowest
  # S package price among the providers
  class SmallShipmentRule
    include Transaction
    # Creates new rule
    # @param [Providers] providers
    def initialize(providers)
      min_price = Float::MAX
      providers.each do |provider|
        provider.packages.each do |size, package|
          min_price = min_price(min_price, package) if size.upcase == 'S'
        end
      end
      @min_price = min_price.freeze
    end

    def apply(transaction)
      return if transaction[PACKAGE_SIZE] != 'S'

      price = transaction[PRICE]
      return if price <= @min_price

      transaction[DISCOUNT] = price - @min_price
      transaction[PRICE] -= transaction[DISCOUNT]
    end

    private

    # @param [Float] current_min
    # @param [ShipDiscount::Providers::Package] package
    # @return [Float] new min
    def min_price(current_min, package)
      current_min > package.price ? package.price.to_f : current_min
    end
  end
end
