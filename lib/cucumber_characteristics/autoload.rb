require 'cucumber_characteristics'

AfterConfiguration do |configuration|
  configuration.options[:formats] << ['CucumberCharacteristics::Formatter', nil]
end
