# frozen_string_literal: true

module Shipdiscount
  # Data file record enumeration and reading provider
  class DataFile
    # Iterate over data file and execute the block for each record
    # @param file_name [String] data file name
    def self.each_record(file_name)
      file = File.new(file_name, 'r')
      file.each_line("\n") do |line|
        fields = line.gsub(/\s+/, ' ').strip.split(' ')
        yield fields
      end
    end

    # Read the whole data file and return it's content
    # @param file_name [String] data file name
    # @return [Array] array of data file records
    def self.read(file_name)
      records = []
      each_record(file_name) { |fields| records << fields }
      records
    end
  end
end
