![](assets/heroku-commander.png)
Heroku::Commander [![Build Status](https://travis-ci.org/dblock/heroku-commander.png?branch=master)](https://travis-ci.org/dblock/heroku-commander)
=================

Master the Heroku CLI from Ruby.

Usage
-----

Add `heroku` and `heroku-commander` to Gemfile.

``` ruby
gem "heroku"
gem "heroku-commander"
```

Heroku Configuration
--------------------

Returns a hash of an application's configuration (output from `heroku config`).


``` ruby
commander = Heroku::Commander.new({ :app => "heroku-commander" })
commander.config # => a hash of all settings for the heroku-commander app
```

Heroku Processes
----------------

Returns or yields an array of processes by running `heroku ps`.

``` ruby
commander = Heroku::Commander.new({ :app => "heroku-commander" })
commander.processes do |process|
  # try process.pid and process.status
end
```

Heroku Run
----------

Executes a command via `heroku run`, pipes and returns output lines. Unlike the heroku client, this also checks the process return code and raises a `Heroku::Commander::Errors::CommandError` if the latter is not zero, which makes this suitable for Rake tasks.

``` ruby
commander = Heroku::Commander.new({ :app => "heroku-commander" })
commander.run "uname -a" # => [ "Linux 2.6.32-348-ec2 #54-Ubuntu SMP x86_64 GNU" ]
```

Heroku Detached Run
-------------------

Executes a command via `heroku run:detached`, spawns a `heroku logs --tail -p pid` for the process started on Heroku, pipes and returns output lines. This also checks the process return code and raises a `Heroku::Commander::Errors::CommandError` if the latter is not zero.

``` ruby
commander = Heroku::Commander.new({ :app => "heroku-commander" })
commander.run("uname -a", { :detached => true }) # => [ "Linux 2.6.32-348-ec2 #54-Ubuntu SMP x86_64 GNU" ]
```

You can examine the output from `heroku logs --tail -p pid` line-by-line.

``` ruby
commander.run("ls -R", { :detached => true }) do |line|
  # each line from the output of the command
end
```

For more information about Heroku one-off dynos see [this documentation](https://devcenter.heroku.com/articles/one-off-dynos).

More Examples
-------------

See [examples](examples) for more.

Contributing
------------

Fork the project. Make your feature addition or bug fix with tests. Send a pull request. Bonus points for topic branches.

Copyright and License
---------------------

MIT License, see [LICENSE](LICENSE.md) for details.

(c) 2013 [Daniel Doubrovkine](http://github.com/dblock), [Frank Macreery](http://github.com/macreery), [Artsy Inc.](http://artsy.net)
