module Heroku
  class Executor

    class Terminate < StandardError

      attr_accessor :timeout

      def initialize(timeout = 0)
        @timeout = timeout
      end
    end

    class << self

      # Executes a command and yields output line-by-line.
      def run(cmd, options = {}, &block)
        lines = []
        running_pid = nil
        logger = options[:logger]
        logger.debug "Running: #{cmd}" if logger
        PTY.spawn(cmd) do |r, w, pid|
          running_pid = pid
          logger.debug "Started: #{pid}" if logger
          terminated = false
          begin
            r.sync = true
            read_from(r, pid, options, lines, &block)
          rescue Heroku::Executor::Terminate => e
            logger.debug "Waiting: #{e.timeout} second(s) to terminate #{pid}" if logger
            # delay terminating of the process, usually to let the output flush
            if timeout
              Thread.new(pid, e.timeout) do |pid, timeout|
                begin
                  sleep(timeout) if timeout
                  ::Process.kill("TERM", pid)
                rescue
                end
              end
            else
              ::Process.kill("TERM", pid)
            end
            terminated = true
          rescue Errno::EIO, IOError => e
            logger.debug "#{e.class}: #{e.message}" if logger
          rescue PTY::ChildExited => e
            logger.debug "Terminated: #{pid}" if logger
            terminated = true
            raise e
          ensure
            unless terminated
              # wait for process
              logger.debug "Waiting: #{pid}" if logger
              ::Process.wait(pid)
            end
          end
        end
        check_exit_status! cmd, running_pid, $?.exitstatus, lines
        lines
      rescue Errno::ECHILD => e
        logger.debug "#{e.class}: #{e.message}" if logger
        check_exit_status! cmd, running_pid, $?.exitstatus, lines
        lines
      rescue PTY::ChildExited => e
        logger.debug "#{e.class}: #{e.message}" if logger
        check_exit_status! cmd, running_pid, $!.status.exitstatus, lines
        lines
      rescue Heroku::Commander::Errors::Base => e
        logger.debug "Error: #{e.problem}" if logger
        raise
      rescue Exception => e
        logger.debug "#{e.class}: #{e.respond_to?(:problem) ? e.problem : e.message}" if logger
        raise Heroku::Commander::Errors::CommandError.new({
          :cmd => cmd,
          :pid => running_pid,
          :status => $?.exitstatus,
          :message => e.message,
          :inner_exception => e,
          :lines => lines
        })
      end

      private

        def read_from(r, pid, options, lines, &block)
          logger = options[:logger]
          while ! r.eof do
            line = r.readline
            line.strip! if line
            logger.debug "#{pid}: #{line}" if logger
            if block_given?
              yield line
            end
            lines << line
          end
        end

        def check_exit_status!(cmd, pid, status, lines = nil)
          return if ! status || status == 0
          raise Heroku::Commander::Errors::CommandError.new({
            :cmd => cmd,
            :pid => pid,
            :status => status,
            :message => "The command #{cmd} failed with exit status #{status}.",
            :lines => lines
          })
        end

    end
  end
end
