module Heroku
  class Executor
    class << self

      # Executes a command and yields output line-by-line.
      def run(cmd, options = {}, &block)
        lines = [] unless block_given?
        logger = options[:logger]
        logger.debug "Running: #{cmd}" if logger
        PTY.spawn(cmd) do |r, w, pid|
          logger.debug "Started: #{pid}" if logger
          begin
            $stdout.sync = true
            r.sync = true
            until r.eof? do
              line = r.readline
              line.chomp!
              if block_given?
                yield line
              else
                lines << line
              end
            end
          rescue Errno::EIO, IOError => e
            logger.debug "Exception: #{e}" if logger
          ensure
            logger.debug "Waiting: #{pid}" if logger
            Process.wait(pid)
          end
        end
        check_exit_status! cmd, $?.exitstatus
        lines ? lines.join("\n") : nil
      rescue PTY::ChildExited => e
        logger.debug "Exception: #{e}" if logger
        check_exit_status! cmd, $!.status.exitstatus
        lines ? lines.join("\n") : nil
      rescue Heroku::Commander::Errors::Base => e
        logger.debug "Exception: #{e}" if logger
        raise
      rescue Exception => e
        logger.debug "Exception: #{e}" if logger
        raise Heroku::Commander::Errors::CommandError.new({
          :cmd => cmd,
          :status => $?.exitstatus,
          :message => e.message,
          :inner_exception => e
        })
      end

      private

        def check_exit_status!(cmd, status)
          raise Heroku::Commander::Errors::CommandError.new({
            :cmd => cmd,
            :status => status,
            :message => "The command #{cmd} failed with exit status #{status}."
          }) unless status == 0
        end

    end
  end
end
