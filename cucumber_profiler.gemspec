# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cucumber_profiler/version'

Gem::Specification.new do |spec|
  spec.name          = "cucumber_profiler"
  spec.version       = CucumberProfiler::VERSION
  spec.authors       = ["Stuart Ingram"]
  spec.email         = ["stuart.ingram@gmail.com"]
  spec.description   = %q{Gem to profile cucumber steps and features}
  spec.summary       = %q{Gem to profile cucumber steps and features}
  spec.homepage      = "https://github.com/singram/cucumber_profiler"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
