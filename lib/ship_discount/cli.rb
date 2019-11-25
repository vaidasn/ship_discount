# frozen_string_literal: true

require 'ship_discount'
require 'optparse'

module ShipDiscount
  # Command Line Interface for shipment discount calculation module
  module CLI
    def self.run
      option_parser, positional_args = parse_options
      file_name = get_file_name_from_args(option_parser, positional_args)
      ShipDiscount.process file_name, $stdout
      exit 0
    end

    def self.parse_options
      positional_args = ARGV.dup
      option_parser = OptionParser.new do |opts|
        add_usage_info(opts)
        opts.on('-h', '--help', 'Show usage information') do
          show_usage_and_exit option_parser
        end
      end
      option_parser.parse! positional_args
      [option_parser, positional_args]
    end

    def self.add_usage_info(opts)
      opts.banner = 'Usage: ship_discount [options] [path]'
      opts.separator '    path    Input file name. ' \
                       'If not specified input.txt is assumed'
      opts.separator 'Options'
    end

    def self.get_file_name_from_args(option_parser, positional_args)
      if positional_args.length > 1
        show_usage_and_exit option_parser,
                            'ERROR: Wrong number of arguments specified'
      end
      file_name = positional_args[0] || 'input.txt'
      unless File.exist? file_name
        show_usage_and_exit option_parser,
                            "ERROR: Input file #{file_name} can not be found"
      end
      file_name
    end

    def self.show_usage_and_exit(option_parser, error_message = nil)
      $stderr.puts option_parser
      $stderr.puts error_message if error_message
      exit 1
    end

    private_class_method :parse_options, :add_usage_info,
                         :get_file_name_from_args, :show_usage_and_exit
  end
end
