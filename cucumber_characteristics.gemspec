# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cucumber_characteristics/version'

Gem::Specification.new do |spec|
  spec.name          = 'cucumber_characteristics'
  spec.version       = CucumberCharacteristics::VERSION
  spec.authors       = ['Stuart Ingram']
  spec.email         = ['stuart.ingram@gmail.com']
  spec.description   = 'Gem to profile cucumber steps and features'
  spec.summary       = 'Gem to profile cucumber steps and features'
  spec.homepage      = 'https://github.com/singram/cucumber_characteristics'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.0'

  spec.add_dependency 'cucumber', '>=1.3.5'
  spec.add_dependency 'haml'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'nokogiri'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
