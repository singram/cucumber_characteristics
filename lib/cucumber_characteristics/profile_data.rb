module CucumberCharacteristics

  class ProfileData

    extend Forwardable

    def_delegators :@runtime, :scenarios, :steps
    attr_reader :duration

    STATUS = [:passed, :failed, :skipped, :undefined ]

    require 'pp'

    def initialize(runtime, features)
      @runtime = runtime
      @duration = features.duration
      @features = features
      feature_profiles
    end

    def ambiguous_count
      @runtime.steps.count{|s| ambiguous?(s)}
    end

    def feature_profiles
#       feature_profiles = { }
#       # @runtime.steps.each do |s|
#       #   unless ambiguous?(s)
#       #     step_name = s.status == :undefined ? s.name : s.step_match.step_definition.file_colon_line
#       #     # Initialize data structure
#       #     step_profiles[step_name] ||= { :total_count => 0}
#       #     STATUS.each {|status| step_profiles[step_name][status] ||= {:count => 0, :feature_location => {} }}
#       #     feature_location = s.file_colon_line
#       #     step_profiles[step_name][s.status][:count] += 1
#       #     step_profiles[step_name][:total_count] += 1
#       #     step_profiles[step_name][s.status][:feature_location][feature_location] ||= []
#       #     if s.status != :undefined
#       #       step_profiles[step_name][:regexp] = s.step_match.step_definition.regexp_source
#       #       if s.status == :passed
#       #         step_profiles[step_name][s.status][:feature_location][feature_location] << s.step_match.duration
#       #       end
#       #     end
#       #   end
#       #   pp s.methods.sort
#       # end
#       #      pp @runtime.methods.sort

#       @features.each do |f|
#         f.feature_elements.each do |fe|
#           pp fe.class.name
#         end
#       end
      @runtime.scenarios.each do |f|
        # #        pp f.methods.sort
#         pp '---------------'
        if f.is_a?(Cucumber::Ast::OutlineTable::ExampleRow)
          pp f.scenario_outline.file_colon_line
          pp f.scenario_outline.name
       #   pp f.scenario_outline.example_rows
          # f.scenario_outline.each_example_row do |ex|
          #   pp 'XXXX'
          #   pp ex.class.name
          #   pp ex.name
          pp f.name
            f.step_invocations.each do |s|
              pp s.step_match.duration
            end
  #        end
        # #          pp f.scenario_outline.methods.sort
#  #         f.scenario_outline.feature.methods.sort
#           f.scenario_outline.
# #            e.methods.sort
#    #       end
# #          pp f.methods.sort
# #          pp f.name
# #          pp f.scenario_outline.step_invocations.each {|x| pp x}
        else
          pp f.file_colon_line
          pp f.name
          # #          pp f.steps.each {|x| pp x.methods.sort}
          pp f.steps.each {|x| pp x.step_match.duration}
        end
#         pp '---------------'

# #         @features.each do |f|
# #           pp f.name
# #           pp f.methods.sort
# #           pp f.feature_elements
# #           pp f.feature_elements.first.methods.sort
# # #          pp f.duration
# #         end
#  #       feature_profiles[f.name] = {status: f.status, location: f.name, duration: f.duration}
      end
#       feature_profiles
    end

    def step_profiles
      step_profiles = {}
      @runtime.steps.each do |s|
        unless ambiguous?(s)
          step_name = s.status == :undefined ? s.name : s.step_match.step_definition.file_colon_line
          # Initialize data structure
          step_profiles[step_name] ||= { :total_count => 0}
          STATUS.each {|status| step_profiles[step_name][status] ||= {:count => 0, :feature_location => {} }}
          feature_location = s.file_colon_line
          step_profiles[step_name][s.status][:count] += 1
          step_profiles[step_name][:total_count] += 1
          step_profiles[step_name][s.status][:feature_location][feature_location] ||= []
          if s.status != :undefined
            step_profiles[step_name][:regexp] = s.step_match.step_definition.regexp_source
            if s.status == :passed
              step_profiles[step_name][s.status][:feature_location][feature_location] << s.step_match.duration
            end
          end
        end
      end
      with_calculations(step_profiles)
    end

    def ambiguous?(step)
      step.status == :failed && step.step_match.step_definition.nil?
    end

    def with_calculations(step_profiles)
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
        sum = timings.inject(0){|accum, i| accum +(i-step_profiles[step][:average])**2 }
        step_profiles[step][:variance] = sum/(timings.length ).to_f
        step_profiles[step][:standard_deviation] = Math.sqrt( step_profiles[step][:variance])
      end
      step_profiles
    end

    def step_duration
      step_duration = []
      step_profiles.each do | step, meta |
        STATUS.each do |status|
          meta[status][:feature_location].each do | location, timings |
            step_duration << timings
          end
        end
      end
      step_duration.flatten.compact.inject(:+)
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
