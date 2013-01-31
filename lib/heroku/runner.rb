module Heroku
  class Runner

    attr_accessor :app, :logger, :command
    attr_reader :pid, :running, :tail

    def initialize(options = {})
      @app = options[:app]
      @logger = options[:logger]
      @command = options[:command]
      raise Heroku::Commander::Errors::MissingCommandError unless @command
    end

    def running?
      !! @running
    end

    def run!(options = {}, &block)
      if options && options[:detached]
        run_detached! &block
      else
        run_attached! &block
      end
    end

    protected

      def run_attached!(&block)
        @pid = nil
        previous_line = nil # delay by 1 to avoid rc=status line
        lines = Heroku::Executor.run cmdline, { :logger => logger } do |line|
          if ! @pid
            check_pid(line)
          elsif block_given?
            yield previous_line if previous_line
            previous_line = line
          end
        end
        lines.shift # remove Running `...` attached to terminal... up, run.xyz
        check_exit_status! lines
        lines
      end

      def run_detached!(&block)
        raise Heroku::Commander::Errors::AlreadyRunningError.new({ :pid => @pid }) if running?
        @running = true
        @pid = nil
        @tail = nil
        lines = Heroku::Executor.run cmdline({ :detached => true }), { :logger => logger } do |line|
          check_pid(line) unless @pid
          @tail ||= tail!(&block) if @pid
        end
        check_exit_status! @tail || lines
        @running = false
        @tail || lines
      end

      def cmdline(options = {})
        [ "heroku", options[:detached] ? "run:detached" : "run", "\"(#{command} 2>&1 ; echo rc=\\$?)\"", @app ? "--app #{@app}" : nil ].compact.join(" ")
      end

      def check_exit_status!(lines)
        status = (lines.size > 0) && (match = lines[-1].match(/^rc=(\d+)$/)) ? match[1] : nil
        lines.pop if status
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
          logger.debug "Heroku pid #{@pid} up." if logger
        elsif (match = line.match /detached... up, (run.\d+)$/)
          @pid = match[1]
          logger.debug "Heroku detached pid #{@pid} up." if logger
        else
          @pid = ''
        end
      end

      def tail!(&block)
        lines = []
        tail_cmdline = [ "heroku", "logs", "-p #{@pid}", "--tail", @app ? "--app #{@app}" : nil ].compact.join(" ")
        Heroku::Executor.run tail_cmdline, { :logger => logger } do |line|
          # remove any ANSI output
          line = line.gsub /\e\[(\d+)m/, ''
          # lines are returned as [date/time] app/heroku[pid]: output
          line = line.split("[#{@pid}]:")[-1].strip
          if line.match(/Starting process with command/) || line.match(/State changed from \w+ to up/)
            # ignore
          elsif line.match(/State changed from \w+ to complete/) || line.match(/Process exited with status \d+/)
            terminate_executor!
          else
            if block_given?
              yield line
            end
            lines << line
          end
        end
        lines
      end

      def terminate_executor!
        raise Heroku::Executor::Terminate
      end

  end
end
