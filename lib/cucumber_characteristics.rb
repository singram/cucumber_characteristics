require 'cucumber_characteristics/configuration'
require 'cucumber_characteristics/cucumber_step_patch'
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
