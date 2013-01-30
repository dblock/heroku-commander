Heroku::Commander [![Build Status](https://travis-ci.org/dblock/heroku-commander.png?branch=master)](https://travis-ci.org/dblock/heroku-commander)
=================

Control Heroku from Ruby via its `heroku` shell command.

Usage
-----

Add `heroku` and `heroku-commander` to Gemfile.

``` ruby
gem "heroku"
gem "heroku-commander"
```

Heroku Configuration
--------------------

``` ruby
commander = Heroku::Commander.new({ :app => "heroku-commander" })
commander.config # => a hash of all settings for the heroku-commander app
```

See [examples](https://github.com/dblock/heroku-commander/tree/master/examples) for more.

Contributing
------------

Fork the project. Make your feature addition or bug fix with tests. Send a pull request. Bonus points for topic branches.

Copyright and License
---------------------

MIT License, see [LICENSE](https://github.com/dblock/heroku-commander/raw/master/LICENSE.md) for details.

(c) 2013 [Daniel Doubrovkine](http://github.com/dblock), [Frank Macreery](http://github.com/macreery), [Artsy Inc.](http://artsy.net)
