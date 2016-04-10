require 'cucumber_characteristics'

AfterConfiguration do |configuration|
  configuration.formats << ['CucumberCharacteristics::Formatter', nil]
end
