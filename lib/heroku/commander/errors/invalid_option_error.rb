module Heroku
  class Commander
    module Errors
      class InvalidOptionError < Heroku::Commander::Errors::Base

        def initialize(opts = {})
          super(compose_message("invalid_option", opts))
        end

      end
    end
  end
end
