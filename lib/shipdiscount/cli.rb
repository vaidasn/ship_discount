require 'optparse'

module Shipdiscount
  class CLI
    def CLI.run
      options = {}
      positional_args = ARGV.dup
      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: shipdiscount [options] [path]"
        opts.separator  "    path                             Iput file name"
        opts.separator  "Options"
        opts.on('-h', '--help', 'Show usage information') do
          STDERR.puts option_parser
          exit 1
        end
      end
      option_parser.parse! positional_args, into: options
      if positional_args.length > 1
        STDERR.puts option_parser
        exit 1
      end
      file_name = positional_args[0] || 'input.txt'
      unless File.exists? file_name
        STDERR.puts 'Failed'
        exit 1
      end
      STDERR.puts 'Succeeded'
      exit 0
    end
  end
end
