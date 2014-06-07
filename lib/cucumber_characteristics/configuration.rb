module CucumberCharacteristics

  class Configuration

    attr_accessor :export_json, :export_html, :target_filename, :relative_path

    def initialize
      @export_json = true
      @export_html = true
      @target_filename =  'cucumber_step_characteristics'
      @relative_path =  'features/characteristics'
    end

    def full_target_filename
      "#{full_dir}/#{@target_filename}"
    end

    def full_dir
      dir = resolve_path_from_root @relative_path
      FileUtils.mkdir_p dir unless File.exists? dir
      dir
    end

    def resolve_path_from_root(rel_path)
      if defined?(Rails)
        Rails.root.join(rel_path)
      elsif defined?(Rake.original_dir)
        File.expand_path(rel_path, Rake.original_dir)
      else
        File.expand_path(rel_path, Dir.pwd)
      end
    end

  end
end
