# frozen_string_literal: true

require 'ship_discount/data_file'
require 'ship_discount/providers'
require 'ship_discount/transaction_converter'
require 'ship_discount/rules'

module ShipDiscount
  # Discount processor
  class DiscountProcessor
    include Transaction

    # Creates new processor
    # @param [String] in_file input file name
    # @param [IO] out_fd output file descriptor
    def initialize(in_file, out_fd)
      @in_file = in_file
      @out_fd = out_fd
      @providers = Providers.new
      @transaction_converter = TransactionConverter.new @providers
      @rules = Rules.new @providers
    end

    def process
      DataFile.each_record @in_file do |fields|
        ignored = true
        catch :invalid_transaction do
          process_transaction(fields)
          ignored = false
        end
        output_ignored_transaction(fields) if ignored
      end
    end

    private

    def process_transaction(fields)
      transaction = @transaction_converter.next_transaction fields
      @rules.apply transaction
      transaction[DISCOUNT] = '-' unless transaction[DISCOUNT]
      output_transaction transaction
    end

    def output_ignored_transaction(fields)
      fields << 'Ignored'
      output_transaction fields
    end

    def output_transaction(values)
      @out_fd.puts(values.map do |v|
        v.is_a?(Float) ? format('%<float>0.2f', float: v) : v
      end.join(' '))
    end
  end
end
