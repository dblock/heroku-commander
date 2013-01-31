module Heroku
  class Commander
    module Errors
      class AlreadyRunningError < Heroku::Commander::Errors::Base

        def initialize(opts)
          super(compose_message("already_running_error", opts))
        end

      end
    end
  end
end
