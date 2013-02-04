module Heroku
  class Process

    attr_accessor :app, :logger, :pid, :status

    def initialize(options = {})
      @app = options[:app]
      @logger = options[:logger]
      @pid = options[:pid]
      @status = options[:status]
      raise Heroku::Commander::Errors::MissingPidError unless @pid
    end

    def refresh_status!
      refreshed = false
      Heroku::Commander.new({ :logger => logger, :app => app }).processes.each do |process|
        next unless ! refreshed && process.pid == pid
        @status = process.status
        refreshed = true
      end
      refreshed
    end

  end
end
