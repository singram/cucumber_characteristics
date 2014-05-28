module CucumberProfiler

  class Formatter

    def initialize(runtime, io, options)
      @runtime = runtime
      @io = io
      @options = options
    end

    def after_features(features)
      profile = ProfileData.new(@runtime, features)
      Exporter.new(profile).export
    end

  end


end
