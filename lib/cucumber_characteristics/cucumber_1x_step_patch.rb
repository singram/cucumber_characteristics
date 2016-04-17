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
      @scenario_profiles = feature_profiles
    end
  end

end
