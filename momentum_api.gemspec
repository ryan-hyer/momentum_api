# coding: utf-8
lib = File.expand_path('../../../momentum_api/lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/momentum_api/version'

Gem::Specification.new do |spec|
  spec.name          = "momentum_api"
  spec.version       = MomentumApi::VERSION
  spec.authors       = ["Kim Miller"]
  spec.email         = ["termmonitor@gmail.com"]
  spec.description   = %q{Momentum API}
  spec.summary       = %q{Allows access to the Momentum Discourse instance}
  spec.homepage      = "http://github.com/gomomentum/momentum_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # spec.add_dependency "faraday", "~> 0.9"
  # spec.add_dependency "faraday_middleware", "~> 0.10"
  # spec.add_dependency "rack", ">= 1.6"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.11"
  spec.add_development_dependency 'rubocop', '~> 0.85'

  spec.add_development_dependency "discourse_api", "~> 0.39"

  # spec.required_ruby_version = '>= 2.2.3'
  
end
