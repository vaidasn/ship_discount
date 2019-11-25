# ship_discount

This gem implements shipment discount calculation module according to requirements in
https://gist.github.com/vintedEngineering/7a24d2bb2ef4189447c6b938604ab030

Module can be used both as command line tool or as API in module `ShipDiscount`.

The module makes the following assumptions that were not strictly defined in the requirements:
* It is assumed that the input file has records in date increasing order.
  Validation marks records as ignored if this is not the case
* The shipment provider data is defined in `lib/ship_discount/providers.txt` following the format of `input.txt` 

## Installation

The module can be installed locally by performing the following commands:

    $ rake build
    $ gem install pkg/ship_discount-*.gem

Then the module can be simply invoked by specifying it's name:

    $ ship_discount
    
assuming that file `input.txt` is available in current directory.

## Usage

Invoke the tool with option `--help` to get usage information:

    $ ship_discount --help

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the unit tests and `rake cucumber` to run integration tests.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To run the module without installing it `bundle exec exe/shipdiscount <file_name>`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vaidasn/ship_discount.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
