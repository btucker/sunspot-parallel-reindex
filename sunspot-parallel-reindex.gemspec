# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sunspot/parallel/reindex/version'

Gem::Specification.new do |spec|
  spec.name          = "sunspot-parallel-reindex"
  spec.version       = Sunspot::Parallel::Reindex::VERSION
  spec.authors       = ["Ben Tucker"]
  spec.email         = ["ben@btucker.net"]
  spec.summary       = %q{Provide parallel reindexing to sunspot}
  spec.description   = %q{Supply `rake sunspot:reindex:parallel` to support multi-process reindexing}
  spec.homepage      = "https://github.com/btucker/sunspot-parallel-reindex"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "sunspot_rails", "~> 2.1.0"
  spec.add_dependency "parallel", "~> 1.3.0"
end
