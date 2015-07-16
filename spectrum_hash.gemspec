# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spectrum_hash/version'

Gem::Specification.new do |spec|
  spec.name          = "spectrum_hash"
  spec.version       = SpectrumHash::VERSION
  spec.authors       = ["Michael Wilson"]
  spec.email         = ["michael.wilson@ualberta.ca"]
  spec.summary       = %q{A library for hashing mass spectra data following the splash definition.}
  spec.description   = %q{A library for hashing mass spectra data following the splash definition.}
  spec.homepage      = ""
  spec.license       = "GPL"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
