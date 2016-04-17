module Cucumber
  class StepDefinitionLight
    unless method_defined?(:file_colon_line)
      def file_colon_line
        location.file_colon_line
      end
    end
  end

  module Core
    module Ast
      module Location
        #  Cucumber::Core::Ast::Location::Precise
        class Precise
          unless method_defined?(:file_colon_line)
            def file_colon_line
              to_s
            end
          end
        end
      end
    end
  end

  module Formatter
    module LegacyApi
      module Ast
        class Scenario
          attr_accessor :steps, :background_steps
        end
      end

      class RuntimeFacade
        def scenario_profiles
          return @scenario_profiles if @scenario_profiles
          feature_profiles = {}

          assign_steps_to_scenarios!
          self.results.scenarios.each do |scenario|
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
              feature_profiles[feature_id][:status] = scenario.status.to_sym
              feature_profiles[feature_id].merge!(aggregate_steps(scenario.steps))
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

          @scenario_profiles = feature_profiles
        end

        private

        def feature_id(scenario)
          if outline_feature?(scenario)
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

        def background_step?(step)
          !step.background.nil?
        end

        def scenario_from(step)
          if outline_step?(step)
            # Match directly to scenario by line number
            self.scenarios.select{ |s|
              s.location.file == step.location.file && s.location.line == step.location.line }.first
          else
            # Match indirectly to preceeding scenario by line number
            # (explicit sort needed for ruby 2.x)
            self.scenarios.select{ |s| s.location.file == step.location.file && s.location.line < step.location.line }.sort{ |a,b| a.location.line <=> b.location.line}.last
          end
        end

        def background_steps_for(scenario_file)
          self.steps.select{ |s| s.location.file == scenario_file &&
                                 background_step?(s) }
        end

        def assign_steps_to_scenarios!
          self.steps.each do |step|
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
          self.scenarios.map { |s| s.location.file }.uniq
        end

        def aggregate_steps(steps)
          { total_duration: steps.reject { |s| [:skipped, :undefined].include?(s.status) }.map { |s| s.duration.nanoseconds.to_f / 1_000_000_000 }.inject(&:+),
            step_count: steps.count }
        end


      end
    end
  end



end
