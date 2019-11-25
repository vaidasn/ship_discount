# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ship_discount/version'

Gem::Specification.new do |spec|
  spec.name          = 'ship_discount'
  spec.version       = ShipDiscount::VERSION
  spec.authors       = ['Vaidas Nargėlas']
  spec.email         = ['vaidas.nargelas@gmail.com']

  spec.summary       = 'Shipment discount calculator'
  spec.description   = 'Shipment discount calculator
See https://gist.github.com/vintedEngineering/7a24d2bb2ef4189447c6b938604ab030'
  spec.homepage      = 'https://github.com/vaidasn/ship_discount'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/vaidasn/ship_discount'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem
  # that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
