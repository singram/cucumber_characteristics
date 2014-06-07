require 'haml'

module CucumberCharacteristics

  class Exporter

    attr_reader :profile
    def initialize(profile)
      @profile = profile
      @config  = CucumberCharacteristics.configuration
    end

    def export
      filename = @config.full_target_filename
      if @config.export_html
        File.open(filename+'.html', 'w') { |file| file.write(to_html) }
        puts "Step characteristics report written to #{filename}.html"
      end
      if @config.export_json
        File.open(filename+'.json', 'w') { |file| file.write(to_json) }
        puts "Step characteristics report written to #{filename}.json"
      end
    end

    def to_html
      template = File.read(File.expand_path('../view/step_report.html.haml', __FILE__))
      haml_engine = Haml::Engine.new(template)
      haml_engine.render(self)
    end

    def to_json
      @profile.step_profiles.to_json
    end

    # HELPERS

    def format_ts(t)
      t ? sprintf("%0.4f", t) : '-'
    end

    def format_step_usage(step_feature_data)
      step_feature_data[:feature_location].map do |location, timings|
        "#{location}" + (timings.count > 1 ? " (x#{timings.count})" : '')
      end.join("\n")
    end

    def step_status_summary(profile)
      status = profile.step_count_by_status
      status.keys.sort.map{|s| status[s]> 0 ? "#{s.capitalize}: #{status[s]}" : nil}.compact.join(', ')
    end

   end

end
