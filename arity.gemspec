# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arity/version'

Gem::Specification.new do |spec|
  spec.name          = "arity"
  spec.version       = Arity::VERSION
  spec.authors       = ["David Feldman"]
  spec.email         = ["dbfeldman@gmail.com"]

  spec.summary       = "logic regarding function arity"
  spec.description   = "logic to determine when Ruby functions can be called"
  spec.homepage      = "https://github.com/fledman/arity"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
end
