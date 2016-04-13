#http://stackoverflow.com/questions/4470108/when-monkey-patching-a-method-can-you-call-the-overridden-method-from-the-new-i

module Cucumber
  class StepMatch
    if self.method_defined?(:invoke)
      old_invoke = instance_method(:invoke)
      attr_reader :duration

      define_method(:invoke) do | multiline_arg |
        start_time = Time.now
        ret = old_invoke.bind(self).(multiline_arg)
        @duration = Time.now - start_time
        ret
      end
    end
  end
end


module Cucumber
  module Ast
    class StepInvocation
      attr_reader :step_match
    end
  end
end

# ============ Cucumber 2.3.3 Patches ===============

module Cucumber
  class StepDefinitionLight
    unless self.method_defined?(:file_colon_line)
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
          unless self.method_defined?(:file_colon_line)
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
    end
  end


end
