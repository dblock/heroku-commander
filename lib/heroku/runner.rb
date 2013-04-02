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
        run_detached! options, &block
      else
        run_attached! options, &block
      end
    end

    protected

      def run_attached!(options = {}, &block)
        @pid = nil
        previous_line = nil # delay by 1 to avoid rc=status line
        lines_until_pid = 0
        lines = Heroku::Executor.run cmdline, { :logger => logger } do |line|
          if ! @pid
            check_pid(line)
            lines_until_pid += 1
          elsif block_given?
            yield previous_line if previous_line
            previous_line = line
          end
        end
        lines.shift(lines_until_pid) # remove Running `...` attached to terminal... up, run.xyz
        check_exit_status! lines
        lines
      end

      def run_detached!(options = {}, &block)
        raise Heroku::Commander::Errors::AlreadyRunningError.new({ :pid => @pid }) if running?
        @running = true
        @pid = nil
        @tail = nil
        lines = Heroku::Executor.run cmdline({ :detached => true }), { :logger => logger } do |line|
          check_pid(line) unless @pid
          @tail ||= tail!(options, &block) if @pid
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
          :pid => @pid,
          :status => status,
          :message => "The command #{@command} failed.",
          :lines => lines
        }) unless status && status == "0"
      end

      def check_pid(line)
        if (match = line.match /up, (run.\d+)$/)
          @pid = match[1]
          logger.debug "Heroku pid #{@pid} up." if logger
        end
      end

      def tail!(options = {}, &block)
        lines = []
        tail_cmdline = [ "heroku", "logs", "-p #{@pid}", "--tail", @app ? "--app #{@app}" : nil ].compact.join(" ")
        previous_line = nil # delay by 1 to avoid rc=status lines
        process_completed = false
        # tail retries
        tail_retries_left = (options[:tail_retries] || 3).to_i
        if tail_retries_left < 0
          raise Heroku::Commander::Errors::InvalidOptionError.new({
            :name => "tail_retries",
            :value => options[:tail_retries],
            :range => "greater or equal to 0"
          })
        end
        # tail timeout
        tail_timeout = (options[:tail_timeout] || 5).to_i
        if tail_timeout < 0
          raise Heroku::Commander::Errors::InvalidOptionError.new({
            :name => "tail_timeout",
            :value => options[:tail_timeout],
            :range => "greater or equal to 0"
          })
        end
        # tail
        process_completed = false
        while ! process_completed
          tail_retries_left -= 1
          begin
            Heroku::Executor.run tail_cmdline, { :logger => logger } do |line|
              line ||= ""
              # remove any ANSI output
              line = line.gsub /\e\[(\d+)m/, ''
              # lines are returned as [date/time] app/heroku[pid]: output
              if (line_after_prefix = line.split("[#{@pid}]:")[-1])
                line = line_after_prefix.strip
              end
              if line.match(/Starting process with command/) || line.match(/State changed from \w+ to up/)
                # ignore
              elsif line.match(/State changed from \w+ to complete/) || line.match(/Process exited with status \d+/)
                process_completed = true
                terminate_executor!(options[:tail_timeout] || 5)
              else
                if block_given?
                  yield previous_line if previous_line
                  previous_line = line
                end
                lines << line
              end
            end
          rescue
            @running = false
            raise if tail_retries_left <= 0
          ensure
            if tail_retries_left <= 0
              @running = false
              raise
            elsif !process_completed
              logger.debug "Restarting #{tail_cmdline}, #{tail_retries_left} #{tail_retries_left == 1 ? 'retry' : 'retries'} left." if logger
            end
          end
        end
        lines
      end

      def terminate_executor!(timeout = 10)
        raise Heroku::Executor::Terminate.new(timeout)
      end

  end
end
