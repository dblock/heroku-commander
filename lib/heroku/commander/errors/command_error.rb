module Heroku
  class Commander
    module Errors
      class CommandError < Heroku::Commander::Errors::Base

        attr_accessor :inner_exception

        def initialize(opts = {})
          @inner_exception = opts[:inner_exception]
          super(compose_message("command_error", opts))
        end
      end
    end
  end
end
