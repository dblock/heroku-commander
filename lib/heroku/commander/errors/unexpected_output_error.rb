module Heroku
  class Commander
    module Errors
      class UnexpectedOutputError < Heroku::Commander::Errors::Base

        attr_accessor :inner_exception

        def initialize(opts)
          super(compose_message("unexpected_output", opts))
        end
      end
    end
  end
end
