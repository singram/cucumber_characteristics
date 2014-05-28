module CucumberProfiler

  class ProfileData

    extend Forwardable

    def_delegators :@runtime, :scenarios, :steps
    attr_reader :duration

    def initialize(runtime, features)
      @runtime = runtime
      @duration = features.duration
    end

    def step_profiles
      return @step_profiles if @step_profiles
      @step_profiles = {}
      @runtime.steps.each do |s|
        step_name = s.status == :undefined ? s.name : s.step_match.step_definition.file_colon_line
        @step_profiles[step_name] ||= {:profile => {}, :passed => 0, :failed => 0, :skipped => 0, :undefined => 0}
        feature_location = s.file_colon_line
        @step_profiles[step_name][s.status] += 1
        @step_profiles[step_name][:profile][feature_location] ||= []
        if s.status != :undefined
          @step_profiles[step_name][:regexp] = s.step_match.step_definition.regexp_source
          if s.status == :passed
            @step_profiles[step_name][:profile][feature_location] << s.step_match.duration
          end
        end
      end
      calculations!
      @step_profiles
    end

    def calculations!
      @step_profiles.each do |step, meta|
        @step_profiles.merge(fastest: nil, slowest: nil, average: nil, total_duration: nil, standard_deviation: nil, variation: nil)
        return unless meta[:profile] && meta[:passed] > 0
        timings = meta[:profile].values.flatten.compact

        @step_profiles[step][:fastest] = timings.min
        @step_profiles[step][:slowest] = timings.max
        @step_profiles[step][:variation] = @step_profiles[step][:slowest] - @step_profiles[step][:fastest]
        @step_profiles[step][:total_duration] = timings.inject(:+)
        @step_profiles[step][:average] = @step_profiles[step][:total_duration] / meta[:passed]
        sum = timings.inject(0){|accum, i| accum +(i-@step_profiles[step][:average])**2 }
        @step_profiles[step][:variance] = sum/(timings.length ).to_f
        @step_profiles[step][:standard_deviation] = Math.sqrt( @step_profiles[step][:variance])
      end

    end

    def step_duration
      step_duration = []
      step_profiles.each do | step, meta |
        meta[:profile].each do | location, timings |
          step_duration << timings
        end
      end
      step_duration.flatten.compact.inject(:+)
    end

    def step_count_by_status
      status = {}
      @runtime.steps.each do |s|
        status[s.status] ||= 0
        status[s.status] += 1
      end
      status
    end

    def scenario_count_by_status
      status = {}
      @runtime.scenarios.each do |s|
        status[s.status] ||= 0
        status[s.status] += 1
      end
      status
    end

  end


end
