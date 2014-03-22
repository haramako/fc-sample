# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nes_tools/version'

Gem::Specification.new do |spec|
  spec.name          = "nes_tools"
  spec.version       = NesTools::VERSION
  spec.authors       = ["HARADA Makoto"]
  spec.email         = ["haramako@gmail.com"]
  spec.summary       = %q{NES development tools.}
  spec.description   = %q{NES development tools.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
