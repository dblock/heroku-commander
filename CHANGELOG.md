Next Release
============
* When the process exit status cannot be determined the error message says "The command failed without returning an exit status." - [@dblock](https://github.com/dblock).
* Added the process ID into the `Heroku::Commander::Errors::CommandError` problem description - [@dblock](https://github.com/dblock).
* Fix: Heroku `run` or `run:detached` output does not always combine "attached to terminal" and "up" status, which causes the runner to incorrectly parse the Heroku PID - [@dblock](https://github.com/dblock).
* Added `Heroku::Commander.processes` that returns or yields an array of `Heroku::Process` by running `heroku ps` - [@dblock](https://github.com/dblock).

0.1.0 (01/31/2013)
==================

* Initial public release with support for `heroku config`, `heroku run` and `heroku run:detached` - [@dblock](https://github.com/dblock), [@macreery](https://github.com/macreery).
