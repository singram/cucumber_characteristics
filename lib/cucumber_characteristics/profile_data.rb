require 'pp'
require 'pry'

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

    # ============== CUCUMBER 2.+ =======================

    def feature_id(scenario)
      if outline_feature?(scenario)
        #        scenario.location.to_s
        scenario_outline_to_feature_id(scenario)
      else
        scenario.location.to_s
      end
    end

    def outline_feature?(scenario)
      scenario.name =~ /Examples \(#\d+\)$/
    end

    def outline_step?(step)
      step.step.class == Cucumber::Core::Ast::ExpandedOutlineStep
    end

    def scenario_from(step)
      if outline_step?(step)
        # Match directly to scenario by line number
        @runtime.scenarios.select do |s|
          s.location.file == step.location.file
        end.select { |s| s.location.line == step.location.line }.first
      else
        # Match indirectly to preceeding scenario by line number
        @runtime.scenarios.select do |s|
          s.location.file == step.location.file
        end.select { |s| s.location.line < step.location.line }.sort { |s| s.location.line }.last
      end
    end

    def background_steps_for(scenario_file)
      earliest_scenario = @runtime.scenarios.select { |s| s.location.file == scenario_file }.sort { |s| s.location.line }.first
      @runtime.steps.select do |s|
        s.location.file ==
          scenario_file
      end.select { |s| s.location.line < earliest_scenario.location.line }
    end

    def assign_steps_to_scenarios
      @runtime.steps.each do |step|
        scenario = scenario_from(step)
        if scenario
          scenario.steps ||= []
          scenario.steps << step
        end
      end
    end

    Feature = Struct.new(:name, :line) #=> Customer
    def scenario_outlines_from_file(file)
      count = 1
      results = []
      File.open(file).each_line do |li|
        results << Feature.new(li, count) if li[/^\s*Scenario Outline:/]
        count += 1
      end
      results
    end

    # List of scenario name and lines from file
    def scenario_outlines(file)
      @feature_outlines ||= {}
      return @feature_outlines[file] if @feature_outlines[file]
      @feature_outlines[file] = scenario_outlines_from_file(file)
    end

    def scenario_outline_to_feature_id(scenario)
      scenarios = scenario_outlines(scenario.location.file)
      scenario_outline = scenarios.select { |s| s.line < scenario.location.line }.sort(&:line).last
      "#{scenario.location.file}:#{scenario_outline.line}"
    end

    def feature_files
      @runtime.scenarios.map { |s| s.location.file }.uniq
    end

    def aggregate_steps(steps)
      { total_duration: steps.reject { |s| [:skipped, :undefined].include?(s.status) }.map { |s| s.duration.nanoseconds.to_f / 1_000_000_000 }.inject(&:+),
        step_count: steps.count }
    end

    # ============== CUCUMBER 2.+ =======================

    def feature_profiles
      return @feature_profiles if @feature_profiles
      feature_profiles = {}
      if CUCUMBER_VERSION > Gem::Version.new('2.0.0')
        assign_steps_to_scenarios
        @runtime.results.scenarios.each do |scenario|
          # Feature id outline is the top level feature defintion
          # aggregating up multiple examples
          feature_id = feature_id(scenario)
          if outline_feature?(scenario)
            feature_profiles[feature_id] ||= { name: scenario.name, total_duration: 0, step_count: 0, examples: {} }
            agg_steps = aggregate_steps(scenario.steps)
            feature_profiles[feature_id][:total_duration] += agg_steps[:total_duration]
            feature_profiles[feature_id][:step_count] += agg_steps[:step_count]

            # First order step associations to scenario examples
            example_id = scenario_from(scenario.steps.first).name.match(/(Examples.*\))/).captures.first
            feature_profiles[feature_id][:examples][example_id] = { total_duration: 0, step_count: 0 }
            feature_profiles[feature_id][:examples][example_id] = aggregate_steps(scenario.steps)
            feature_profiles[feature_id][:examples][example_id][:status] = scenario.status.to_sym
          else
            feature_profiles[feature_id] = { name: scenario.name, total_duration: 0, step_count: 0 }
            feature_profiles[feature_id].merge!(aggregate_steps(scenario.steps))
            feature_profiles[feature_id][:status] = scenario.status.to_sym
          end
        end
        # Collect up background tasks not directly attributable to
        # specific scenarios
        feature_files.each do |file|
          steps = background_steps_for(file)
          next if steps.empty?
          feature_id = "#{file}:0 (Background)"
          feature_profiles[feature_id] = { name: 'Background', total_duration: 0, step_count: 0 }
          feature_profiles[feature_id].merge!(aggregate_steps(steps))
          feature_profiles[feature_id][:status] =
            steps.map(&:status).uniq.join(',')
        end
      else
        @runtime.scenarios.each do |f|
          if f.is_a?(Cucumber::Ast::OutlineTable::ExampleRow)
            feature_id = f.scenario_outline.file_colon_line
            feature_profiles[feature_id] ||= { name: f.scenario_outline.name, total_duration: 0, step_count: 0, example_count: 0, examples: {} }
            example_id = f.name
            feature_profiles[feature_id][:examples][example_id] ||= { total_duration: 0, step_count: 0 }
            feature_profiles[feature_id][:examples][example_id][:total_duration] = f.instance_variable_get(:@step_invocations).select { |s| s.status == :passed }.map { |s| s.step_match.duration }.inject(&:+)
            feature_profiles[feature_id][:examples][example_id][:step_count] = f.instance_variable_get(:@step_invocations).count
            feature_profiles[feature_id][:examples][example_id][:status] = f.status
          else
            feature_id = f.file_colon_line
            feature_profiles[feature_id] = { name: f.name, total_duration: 0, step_count: 0 }
            feature_profiles[feature_id][:total_duration] = f.steps.select { |s| s.status == :passed }.map { |s| s.step_match.duration }.inject(&:+)
            feature_profiles[feature_id][:step_count] = f.steps.count
            feature_profiles[feature_id][:status] = f.status
          end
        end
      end
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
