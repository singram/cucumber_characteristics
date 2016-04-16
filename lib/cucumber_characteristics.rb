require 'cucumber_characteristics/configuration'
require 'cucumber_characteristics/cucumber_common_step_patch'
if Cucumber::VERSION < '2.0.0'
  require 'cucumber_characteristics/cucumber_1x_step_patch'
else
  require 'cucumber_characteristics/cucumber_2x_step_patch'
end
require 'cucumber_characteristics/exporter'
require 'cucumber_characteristics/formatter'
require 'cucumber_characteristics/profile_data'

module CucumberCharacteristics
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
