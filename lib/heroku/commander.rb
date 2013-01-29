module Heroku
  class Commander

    attr_accessor :app, :config

    def initialize(options = {})
      @app = options[:app] if options
    end

    # Returns a loaded Heroku::Config instance.
    def config
      @config ||= Heroku::Config.new({ :app => app }).tap do |config|
        config.reload!
      end
    end

  end
end
