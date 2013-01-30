require 'bundler'
Bundler.setup(:default, :development)

require 'heroku-commander'

logger = Logger.new($stdout)
logger.level = Logger::DEBUG
commander = Heroku::Commander.new({ :logger => logger })
config = commander.config
config.each_pair do |name, value|
  logger.info "#{name}: #{value}"
end
