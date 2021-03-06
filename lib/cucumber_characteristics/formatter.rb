module CucumberCharacteristics
  class Formatter
    def initialize(runtime, io, options)
      @runtime = runtime
      @io = io
      @options = options
      @features = {}
    end

    def after_features(features)
      profile = ProfileData.new(@runtime, features)
      Exporter.new(profile).export
    end
  end
end
