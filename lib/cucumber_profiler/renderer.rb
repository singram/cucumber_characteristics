require 'haml'

module CucumberProfiler

  class Renderer

    attr_reader :profile
    def initialize(profile)
      @profile = profile
      @config  = Configuration
    end

    def render
      template = File.read(File.expand_path('../view/step_report.html.haml', __FILE__))
      haml_engine = Haml::Engine.new(template)
      html_output = haml_engine.render(self)
      File.open(@config.full_target_filename, 'w') { |file| file.write(html_output) }
      puts "Step report written to #{@config.full_target_filename}"
    end

    # HELPERS

    def format_ts(t)
      t ? sprintf("%0.4f", t) : '-'
    end

    def step_status_summary(profile)
      status = profile.step_count_by_status
      status.keys.sort.map{|s| status[s]>0 ? "#{s.capitalize}: #{status[s]}" : nil}.compact.join(', ')
    end

   end

end
