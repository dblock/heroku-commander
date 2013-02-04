require 'bundler'
Bundler.setup(:default, :development)

require 'heroku-commander'

logger = Logger.new($stdout)
logger.level = Logger::DEBUG
commander = Heroku::Commander.new({ :logger => logger })

commander.processes.each do |process|
  logger.info "Process: #{process.pid} (#{process.status})"
end
