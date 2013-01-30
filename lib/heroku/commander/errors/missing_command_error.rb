module Heroku
  class Commander
    module Errors
      class MissingCommandError < Heroku::Commander::Errors::Base

        def initialize
          super(compose_message("missing_command_error"))
        end

      end
    end
  end
end
