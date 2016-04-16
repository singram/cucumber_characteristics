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
    end
  end
end
