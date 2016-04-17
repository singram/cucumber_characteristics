require 'pp'

module CucumberCharacteristics
  class ProfileData
    CUCUMBER_VERSION = Gem::Version.new(Cucumber::VERSION)

    extend Forwardable

    def_delegators :@runtime, :scenarios, :steps
    attr_reader :duration

    STATUS_ORDER = { passed: 0, failed: 2000, skipped: 1000, undefined: 500 }.freeze

    STATUS = STATUS_ORDER.keys

    def initialize(runtime, features)
      @runtime = runtime
      @duration = features.duration
      @features = features
    end

    def ambiguous_count
      @runtime.steps.count { |s| ambiguous?(s) }
    end

    def unmatched_steps
      unmatched = {}
      @runtime.unmatched_step_definitions.each do |u|
        location = u.file_colon_line
        unmatched[location] = u.regexp_source
      end
      unmatched.sort
    end

    def unmatched_steps?
      unmatched_steps.count > 0
    end

    def feature_profiles
      return @feature_profiles if @feature_profiles
      feature_profiles = @runtime.scenario_profiles
      @feature_profiles = with_feature_calculations(feature_profiles)
    end

    def with_feature_calculations(feature_profiles)
      feature_profiles.each do |feature, meta|
        next unless meta[:examples]
        feature_profiles[feature][:example_count] = meta[:examples].keys.count
        feature_profiles[feature][:total_duration] = meta[:examples].map { |_e, m| m[:total_duration] || 0 }.inject(&:+)
        feature_profiles[feature][:step_count] = meta[:examples].map { |_e, m| m[:step_count] }.inject(&:+)
        feature_profiles[feature][:examples] = feature_profiles[feature][:examples].sort_by { |_k, v| v[:total_duration] }.reverse
        feature_profiles[feature][:status] = if meta[:examples].all? { |_e, m| m[:status] == :passed }
                                               :passed
                                             elsif meta[:examples].any? { |_e, m| m[:status] == :failed }
                                               :failed
                                             elsif meta[:examples].any? { |_e, m| m[:status] == :skipped }
                                               :skipped
                                             else
                                               :unknown
                                             end
      end
      feature_profiles.sort_by { |_k, v| (STATUS_ORDER[v[:status]] || 0) + (v[:total_duration] || 0) }.reverse
    end

    def step_profiles
      step_profiles = {}
      @runtime.steps.each do |s|
        next if ambiguous?(s)
        step_name = s.status == :undefined ? s.name : s.step_match.step_definition.file_colon_line
        # Initialize data structure
        step_profiles[step_name] ||= { total_count: 0 }
        STATUS.each { |status| step_profiles[step_name][status] ||= { count: 0, feature_location: {} } }
        feature_location = s.file_colon_line
        step_profiles[step_name][s.status][:count] += 1
        step_profiles[step_name][:total_count] += 1
        step_profiles[step_name][s.status][:feature_location][feature_location] ||= []
        next unless s.status != :undefined
        step_profiles[step_name][:regexp] = s.step_match.step_definition.regexp_source
        if s.status == :passed
          step_profiles[step_name][s.status][:feature_location][feature_location] << s.step_match.duration
        end
      end
      with_step_calculations(step_profiles)
    end

    def ambiguous?(step)
      step.status == :failed && step.step_match.step_definition.nil?
    end

    def with_step_calculations(step_profiles)
      step_profiles.each do |step, meta|
        meta.merge!(fastest: nil, slowest: nil, average: nil, total_duration: nil, standard_deviation: nil, variation: nil)
        next unless meta[:passed][:count] > 0
        timings = []
        STATUS.each do |status|
          timings << meta[status][:feature_location].values
        end
        timings = timings.flatten.compact

        step_profiles[step][:fastest] = timings.min
        step_profiles[step][:slowest] = timings.max
        step_profiles[step][:variation] = step_profiles[step][:slowest] - step_profiles[step][:fastest]
        step_profiles[step][:total_duration] = timings.inject(:+)
        step_profiles[step][:average] = step_profiles[step][:total_duration] / meta[:passed][:count]
        sum = timings.inject(0) { |accum, i| accum + (i - step_profiles[step][:average])**2 }
        step_profiles[step][:variance] = sum / timings.length.to_f
        step_profiles[step][:standard_deviation] = Math.sqrt(step_profiles[step][:variance])
      end
      step_profiles.sort_by { |_k, v| v[:total_duration] || 0 }.reverse
    end

    def step_duration
      step_duration = []
      step_profiles.each do |_step, meta|
        STATUS.each do |status|
          meta[status][:feature_location].each do |_location, timings|
            step_duration << timings
          end
        end
      end
      step_duration.flatten.compact.inject(:+) || 0
    end

    def nonstep_duration
      duration - step_duration
    end

    def step_count_by_status
      status = {}
      @runtime.steps.each do |s|
        status[s.status] ||= 0
        status[s.status] += 1
      end
      status
    end

    def step_count(status)
      step_count_by_status[status]
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
