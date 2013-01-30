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

  end
end
