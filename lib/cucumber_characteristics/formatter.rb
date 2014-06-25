module CucumberCharacteristics

  class Formatter

    def initialize(runtime, io, options)
      @runtime = runtime
      @io = io
      @options = options
      @features = {}
    end

    # def before_feature(scenario)
    #   pp scenario.class.name
    #   if scenario.is_a?(Cucumber::Ast::OutlineTable::ExampleRow)
    #     feature_location = scenario.scenario_outline.file_colon_line
    #     feature_name     = scenario.scenario_outline.name.chomp
    #     feature_example  = scenario.name
    #     @features[feature_location] ||= {}
    #     @features[feature_location][feature_example] ||= {start_time: Time.now}
    #   else
    #     feature_location = scenario.file_colon_line
    #     feature_name     = scenario.name.chomp
    #     @features[feature_location] ||= {start_time: Time.now}
    #   end
    # end

    # def after_feature(scenario)
    # end

    def after_features(features)
      profile = ProfileData.new(@runtime, features)
      Exporter.new(profile).export
    end

  end


end
