module Cucumber
  class Runtime
    def scenario_profiles
      return @scenario_profiles if @scenario_profiles
      feature_profiles = {}
      scenarios.each do |f|
        if f.is_a?(Cucumber::Ast::OutlineTable::ExampleRow)
          feature_id = f.scenario_outline.file_colon_line
          feature_profiles[feature_id] ||= { name: f.scenario_outline.name, total_duration: 0, step_count: 0, example_count: 0, examples: {} }
          example_id = f.name
          feature_profiles[feature_id][:examples][example_id] = scenario_outline_example_profile(f)
        else
          feature_id = f.file_colon_line
          feature_profiles[feature_id] = scenario_profile(f)
        end
      end
      @scenario_profiles = feature_profiles
    end

    private

    def scenario_profile(scenario)
      scenario_profile = { name: scenario.name, total_duration: 0, step_count: 0 }
      scenario_profile[:total_duration] = scenario.steps.select { |s| s.status == :passed }.map { |s| s.step_match.duration }.inject(&:+)
      scenario_profile[:step_count] = scenario.steps.count
      scenario_profile[:status] = scenario.status
      scenario_profile
    end

    def scenario_outline_example_profile(scenario)
      example_profile = { total_duration: 0, step_count: 0 }
      example_profile[:total_duration] = scenario.instance_variable_get(:@step_invocations).select { |s| s.status == :passed }.map { |s| s.step_match.duration }.inject(&:+)
      example_profile[:step_count] = scenario.instance_variable_get(:@step_invocations).count
      example_profile[:status] = scenario.status
      example_profile
    end
  end
end
