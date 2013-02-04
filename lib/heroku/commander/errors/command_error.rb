module Heroku
  class Commander
    module Errors
      class CommandError < Heroku::Commander::Errors::Base

        attr_accessor :inner_exception

        def initialize(opts = {})
          @inner_exception = opts[:inner_exception]
          opts = opts.dup
          prepare_lines(opts)
          prepare_status_message(opts)
          prepare_pid(opts)
          super(compose_message("command_error", opts))
        end

        private

          def prepare_status_message(opts)
            if opts[:status] && opts[:status] != ""
              opts[:status_message] = " with exit status #{opts[:status]}"
            else
              opts[:status_message] = " without reporting an exit status"
            end
          end

          def prepare_lines(opts)
            if opts[:lines] && opts[:lines].size > 4
              lines = opts[:lines][0..2]
              lines.push "... skipping #{opts[:lines].size - 4} line(s) ..."
              lines.concat opts[:lines][-2..-1]
              opts[:lines] = "\n\t" + lines.join("\n\t")
            elsif opts[:lines]
              opts[:lines] = "\n\t" + opts[:lines].join("\n\t")
            end
          end

          def prepare_pid(opts)
            if opts[:pid]
              opts[:pid] = " (pid: #{opts[:pid]})"
            end
          end

      end
    end
  end
end
