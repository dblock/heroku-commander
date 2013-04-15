require 'bundler'
Bundler.setup(:default, :development)

require 'heroku-commander'

logger = Logger.new($stdout)
logger.level = Logger::DEBUG
commander = Heroku::Commander.new({ :logger => logger })

uname = commander.run "uname -a", { :size => "2X" }
logger.info "Heroku dyno is a #{uname.join('\n')}."

files = []
commander.run "ls -1" do |line|
  files << line
end
logger.info "The Heroku file system has #{files.count} file(s): #{files.join(', ')}"
