module Heroku
  class Config < Hash

    attr_accessor :app

    def initialize(options = {})
      @app = options[:app] if options
    end

    def reload!
      clear
      cmd = cmdline
      Heroku::Executor.run cmd do |line|
        parts = line.split "=", 2
        raise Heroku::Commander::Errors::UnexpectedOutputError.new({
          :cmd => cmd,
          :line => line
        }) if parts.size != 2
        self[parts[0].strip] = parts[1].strip
      end
      self
    end

    protected

      def cmdline
        [ "heroku", "config", "-s", @app ? "--app #{@app}" : nil ].compact.join(" ")
      end

  end
end
