module CucumberProfiler

  class Formatter

    def initialize(runtime, io, options)
      @runtime = runtime
      @io = io
      @options = options
    end

    def after_features(features)
      @steps = {}
      @runtime.steps.each do |s|
        step_name = s.status == :undefined ? s.name : s.step_match.step_definition.file_colon_line
        @steps[step_name] ||= {:profile => {}, :passed => 0, :failed => 0, :skipped => 0, :undefined => 0}
        feature_location = s.file_colon_line
        @steps[step_name][s.status] += 1
        @steps[step_name][:profile][feature_location] ||= []
        if s.status != :undefined
          @steps[step_name][:regexp] = s.step_match.step_definition.regexp_source
          @steps[step_name][:profile][feature_location] << s.step_match.duration if s.status != :skipped
        end
      end
      pp @steps
    end

  end


end
