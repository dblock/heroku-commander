module Heroku
  class Executor
    class << self

      # Executes a command and yields output line-by-line.
      def run(cmd, options = {}, &block)
        lines = []
        logger = options[:logger]
        logger.debug "Running: #{cmd}" if logger
        PTY.spawn(cmd) do |r, w, pid|
          logger.debug "Started: #{pid}" if logger
          begin
            $stdout.sync = true
            r.sync = true
            until r.eof? do
              line = r.readline
              line.strip!
              if block_given?
                yield line
              end
              lines << line
            end
          rescue Errno::EIO, IOError => e
            logger.debug "Exception: #{e.respond_to?(:problem) ? e.problem : e.message}" if logger
          ensure
            logger.debug "Waiting: #{pid}" if logger
            Process.wait(pid)
          end
        end
        check_exit_status! cmd, $?.exitstatus, lines
        lines
      rescue PTY::ChildExited => e
        logger.debug "Exception: #{e.respond_to?(:problem) ? e.problem : e.message}" if logger
        check_exit_status! cmd, $!.status.exitstatus, lines
        lines
      rescue Heroku::Commander::Errors::Base => e
        logger.debug "Exception: #{e.respond_to?(:problem) ? e.problem : e.message}" if logger
        raise
      rescue Exception => e
        logger.debug "Exception: #{e.respond_to?(:problem) ? e.problem : e.message}" if logger
        raise Heroku::Commander::Errors::CommandError.new({
          :cmd => cmd,
          :status => $?.exitstatus,
          :message => e.message,
          :inner_exception => e,
          :lines => lines
        })
      end

      private

        def check_exit_status!(cmd, status, lines = nil)
          return if status == 0
          raise Heroku::Commander::Errors::CommandError.new({
            :cmd => cmd,
            :status => status,
            :message => "The command #{cmd} failed with exit status #{status}.",
            :lines => lines
          })
        end

    end
  end
end
