# frozen_string_literal: true

require 'ship_discount/data_file'

module ShipDiscount
  # Encapsulates shipping providers
  class Providers
    Package = Struct.new(:size, :price)
    Provider = Struct.new(:name, :packages)

    # Creates new providers from predefined configuration
    def initialize
      provider_builders = read_provider_builders
      @providers = Hash[provider_builders.map do |name, package_hash|
        packages = Hash[package_hash.map do |size, price|
          [size, Package.new(size, price)]
        end]
        [name, Provider.new(name, packages)]
      end]
    end

    # Gets provider by name
    # @param [String] name provider name
    # @return [Providers::Provider]
    def [](name)
      @providers[name]
    end

    def each
      @providers.each { |_n, p| yield p }
    end

    private

    def read_provider_builders
      providers_txt = File.join(File.dirname(__FILE__), 'providers.txt')
      provider_builders = {}
      DataFile.each_record(providers_txt) do |r|
        provider_builder = provider_builders[r[0]]
        provider_builders[r[0]] = provider_builder = {} unless provider_builder
        provider_builder[r[1]] = r[2].to_f
      end
      provider_builders
    end
  end
end
