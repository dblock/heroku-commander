module Heroku
  class Executor
    class << self

      # Executes a command and yields output line-by-line.
      def run(cmd, &block)
        lines = [] unless block_given?
        PTY.spawn(cmd) do |r, w, pid|
          begin
            $stdout.sync = true
            r.sync = true
            r.each do |line|
              line.chomp!
              if block_given?
                yield line
              else
                lines << line
              end
            end
            Process.wait(pid)
          rescue Errno::EIO
            raise Heroku::Commander::Errors::ClientEIOError.new
          end
        end
        check_exit_status! cmd, $?.exitstatus
        lines ? lines.join("\n") : nil
      rescue PTY::ChildExited
        check_exit_status! cmd, $!.status.exitstatus
        lines ? lines.join("\n") : nil
      rescue Heroku::Commander::Errors::Base
        raise
      rescue Exception => e
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
