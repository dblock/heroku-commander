module Heroku
  class Commander
    module Errors
      class ClientEIOError < Heroku::Commander::Errors::Base
        def initialize
          super(compose_message("client_eio"))
        end
      end
    end
  end
end
