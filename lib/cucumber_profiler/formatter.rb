module CucumberProfiler

  class Formatter

    def initialize(step_mother, io, options)
      @step_mother = step_mother
      @io = io
      @options = options
    end

    #----------------------------------------------------
    # Step callbacks
    #----------------------------------------------------
    def before_step(step)
    end

    def before_step_result(*args)
    end

    def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
    end

    def after_step(step)
    end

    #----------------------------------------------------
    # Feature callbacks
    #----------------------------------------------------
    def before_features(features)
    end

    def before_feature(feature)
    end

    def scenario_name(keyword, name, file_colon_line, source_indent)
    end

    def after_feature(feature)
    end

    def after_features(features)
    end

  end

end
