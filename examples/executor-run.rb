require 'bundler'
Bundler.setup(:default, :development)

require 'heroku-commander'

logger = Logger.new($stdout)
logger.level = Logger::INFO

uname = Heroku::Executor.run "uname -a", { :logger => logger }
logger.info "Local system is #{uname.join('\n')}."

files = []
Heroku::Executor.run "ls -1", { :logger => logger } do |line|
  files << line
end
logger.info "Local file system has #{files.count} file(s): #{files.join(', ')}"
