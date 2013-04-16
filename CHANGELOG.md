0.3.1 (04/16/2013)
==================
* Fixed syntax error for heroku command-line, when specifying a `size` option - [@mzikherman](https://github.com/mzikherman).

0.3.0 (04/15/2013)
==================
* Fixed an infinite loop in the tail restart method used by `Heroku::Commander.run` with `detached: true` - [@macreery](https://github.com/macreery).
* The `Heroku::Commander.run` with `detached: true` will now restart the tail process when aborted without having received a process exit message - [@dblock](https://github.com/dblock).
* Added a `tail_retries` that defines the maximum number of tail restarts, default is 3 - [@dblock](https://github.com/dblock).
* Added a `size` option to `Heroku::Runner` and `Heroku::Commander.run`, supporting `2X` dynos - [@dblock](https://github.com/dblock).

0.2.0 (02/14/2013)
==================

* When the process exit status cannot be determined the error message says "The command failed without returning an exit status." - [@dblock](https://github.com/dblock).
* Added the process ID into the `Heroku::Commander::Errors::CommandError` problem description - [@dblock](https://github.com/dblock).
* Fix: Heroku `run` or `run:detached` output does not always combine "attached to terminal" and "up" status, which causes the runner to incorrectly parse the Heroku PID - [@dblock](https://github.com/dblock).
* Added `Heroku::Commander.processes` that returns or yields an array of `Heroku::Process` by running `heroku ps` - [@dblock](https://github.com/dblock).
* Added a `tail_timeout` option to `Heroku::Commander.run` with `detached: true` that suspends tail process termination for a chance to receive additional `heroku logs --tail` output - [@dblock](https://github.com/dblock).

0.1.0 (01/31/2013)
==================

* Initial public release with support for `heroku config`, `heroku run` and `heroku run:detached` - [@dblock](https://github.com/dblock), [@macreery](https://github.com/macreery).
