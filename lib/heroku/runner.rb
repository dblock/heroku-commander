module Heroku
  class Runner

    attr_accessor :app, :logger, :command, :pid

    def initialize(options = {})
      @app = options[:app]
      @logger = options[:logger]
      @command = options[:command]
      raise Heroku::Commander::Errors::MissingCommandError unless @command
    end

    def run!(&block)
      lines = Heroku::Executor.run cmdline, { :logger => logger } do |line|
        check_pid(line) unless @pid
        if block_given?
          yield line
        end
      end
      check_exit_status! lines
      lines.shift # removes Running `...` attached to terminal... up, run.pid
      lines.pop # remove rc=status
      lines
    end

    protected

      def cmdline
        [ "heroku", "run", "\"(#{command} 2>&1 ; echo rc=\\$?)\"", @app ? "--app #{@app}" : nil ].compact.join(" ")
      end

      def check_exit_status!(lines)
        status = (lines.size > 0) && (match = lines[-1].match(/^rc=(\d+)$/)) ? match[1] : nil
        raise Heroku::Commander::Errors::CommandError.new({
          :cmd => @command,
          :status => status,
          :message => "The command #{@command} failed with exit status #{status}.",
          :lines => lines
        }) unless status && status == "0"
      end

      def check_pid(line)
        if (match = line.match /attached to terminal... up, (run.\d+)$/)
          @pid = match[1]
        else
          @pid = ''
        end
      end

  end
end
