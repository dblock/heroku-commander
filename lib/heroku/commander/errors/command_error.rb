module Heroku
  class Commander
    module Errors
      class CommandError < Heroku::Commander::Errors::Base

        attr_accessor :inner_exception

        def initialize(opts = {})
          @inner_exception = opts[:inner_exception]
          super(compose_message("command_error", prepare_lines(opts)))
        end

        private

          def prepare_lines(opts)
            if opts[:lines] && opts[:lines].size > 4
              lines = opts[:lines][0..2]
              lines.push "... skipping #{opts[:lines].size - 4} line(s) ..."
              lines.concat opts[:lines][-2..-1]
              result = opts.dup
              result[:lines] = "\n\t" + lines.join("\n\t")
              result
            elsif opts[:lines]
              result = opts.dup
              result[:lines] = "\n\t" + result[:lines].join("\n\t")
              result
            else
              opts
            end
          end
      end
    end
  end
end
