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

    # Run a process synchronously
    def run(command, &block)
      runner = Heroku::Runner.new({ :app => app, :logger => logger, :command => command })
      runner.run! &block
    end

  end
end
