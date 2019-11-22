# frozen_string_literal: true

require 'shipdiscount/providers'

module Shipdiscount
  # Rule: All S shipments should always match the lowest
  # S package price among the providers
  class SmallSizeRule
    # Creates new rule
    # @param [Shipdiscount::Providers] providers
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
      return if transaction[1] != 'S'

      price = transaction[3]
      transaction[4] = price - @min_price if price > @min_price
    end

    private

    # @param [Float] current_min
    # @param [Shipdiscount::Providers::Package] package
    # @return [Float] new min
    def min_price(current_min, package)
      current_min > package.price ? package.price.to_f : current_min
    end
  end
end
