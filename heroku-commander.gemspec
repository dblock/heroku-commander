$:.push File.expand_path("../lib", __FILE__)
require "heroku/commander/version"

Gem::Specification.new do |s|
  s.name = "heroku-commander"
  s.version = Heroku::Commander::VERSION
  s.authors = [ "Daniel Doubrovkine", "Frank Macreery" ]
  s.email = "dblock@dblock.org"
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = `git ls-files`.split("\n")
  s.require_paths = [ "lib" ]
  s.homepage = "http://github.com/dblock/heroku-commander"
  s.licenses = [ "MIT" ]
  s.summary = "Control Heroku from Ruby via its `heroku` shell command."
  s.add_dependency "heroku"
  s.add_dependency "i18n"
end


