module Heroku
  class Commander
    module Errors
      class NoSuchProcessError < Heroku::Commander::Errors::Base

        def initialize(opts = {})
          super(compose_message("no_such_process", opts))
        end

      end
    end
  end
end
