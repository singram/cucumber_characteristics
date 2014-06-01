require "cucumber_profiler/configuration"
require "cucumber_profiler/cucumber_step_patch"
require "cucumber_profiler/exporter"
require "cucumber_profiler/formatter"
require "cucumber_profiler/profile_data"

module CucumberProfiler
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
