module Heroku
  class Commander

    attr_accessor :app, :logger, :config

    def initialize(options = {})
      @app = options[:app]
      @logger = options[:logger]
    end

    # Returns a loaded Heroku::Config instance.
    def config
      @config ||= Heroku::Config.new({ :app => app, :logger => logger }).tap do |config|
        config.reload!
      end
    end

    def processes(&block)
      processes = []
      cmdline = [ "heroku", "ps", @app ? "--app #{@app}" : nil ].compact.join(" ")
      Heroku::Executor.run cmdline, { :logger => logger } do |line|
        next if ! line || line[0] == '=' || line.length == 0
        if (match = line.match /(\w+\.\d+): (\w+)/)
          process = Heroku::Process.new({ :logger => logger, :pid => match[1], :status => match[2], :app => app })
          processes << process
          logger.info "Process: #{process.pid} (#{process.status}) from '#{line}'" if logger
          yield process if block_given?
        else
          logger.warn "Unexpected line from heroku ps: #{line}" if logger
        end
      end
      processes
    end

    # Run a process synchronously
    def run(command, options = {}, &block)
      size = options.delete(:size) if options
      runner = Heroku::Runner.new({ :app => app, :logger => logger, :command => command, size: size })
      runner.run!(options, &block)
    end

  end
end
