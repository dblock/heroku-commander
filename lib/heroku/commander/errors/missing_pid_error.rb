module Heroku
  class Commander
    module Errors
      class MissingPidError < Heroku::Commander::Errors::Base

        def initialize
          super(compose_message("missing_pid_error"))
        end

      end
    end
  end
end
