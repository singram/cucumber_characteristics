module CucumberProfiler

  class Formatter

    def initialize(runtime, io, options)
      @runtime = runtime
      @io = io
      @options = options
#      @step_profiler = CucumberProfiler::StepProfiler.new
    end

#     #----------------------------------------------------
#     # Step callbacks
#     #----------------------------------------------------
#     def before_step(step)
#       #      pp step
#       # pp '========='
#       # pp step.methods.sort
#       # pp step.gherkin_statement
#       # pp step.file_colon_line
#       # pp step.backtrace_line
#       # pp step.class.name
#       @step_instance = CucumberProfiler::StepInstanceProfile.new(step.file_colon_line)
# #      puts
# #      pp 'Before step'
# #      pp step.file_colon_line
#       @step_instance.start
#     end

#     def before_table_cell(*args)
# #      pp 'xxxxxxxxxxx'
# #      args.each {|a| pp a.class.name}
# #      pp '--------'
#     end

#     def step_name(keyword, step_match, multiline_arg,status, source_indent, background)
# #      pp 'Step name'
# #      pp step_match
#     end

#     def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, feature_file_colon_line)
# #      pp 'Before step result'
#       @step_instance.end(feature_file_colon_line, step_match)
#       @step_profiler << @step_instance
#     end

#     def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
# #      pp 'After step result'
#       if exception
# #        pp exception
#       end
#       unless status == :passed
# #        pp status
# #        pp file_colon_line
#       end
#     end

#     def after_step(step)
#     end

#     def before_outline_table(outline_table)
#     end

#     def after_table_row(table_row)
#     end

#     def scenario_name(*args)
#     end

#     def examples_name(*args)
#     end

#     #----------------------------------------------------
#     # Feature callbacks
#     #----------------------------------------------------
#     def before_features(features)
#     end

#     def before_feature(feature)
#     end

#     def scenario_name(keyword, name, file_colon_line, source_indent)
#     end

#     def after_feature(feature)
#     end

    def after_features(features)
#      pp @step_profiler.to_s
      #      pp 'Awesome print'
      @runtime.steps(:passed).each do |s|
        pp s.class.name;
        #        pp s.methods.sort
        pp s.file_colon_line
        pp s.step_match.step_definition.file_colon_line
        pp s.step_match.step_definition.regexp_source
        pp s.step_match.format_args
        pp s.step_match.duration
      end
#      ap @step_profiler.to_s
#      ap @step_profiler.steps.count
#      ap @runtime.steps(:passed)
    end

  end


end
