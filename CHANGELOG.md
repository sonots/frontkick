# 0.5.3 (2017/01/12)

Fixes:

- Fix not to close given out and err IO objects

# 0.5.2 (2016/03/18)

Fixes:

- Fix not to return exitstatus 0 when a child process is killed by -9 (Now, exitstatus becomes nil as Open3.popen3)

# 0.5.1 (2016/01/23)

Changes:

- Drop :kill_child option, instead, support pid block

# 0.5.0 (2016/01/22)

Enhancements:

- Add :out and :err options to redirects STDOUT and STDERR

# 0.4.9 (2016/01/22)

Enhancements:

- Support spawn options

# 0.4.8 (2016/01/22)

Fixes:

- Fix kill_child option

# 0.4.7 (2016/01/22)

Enhancements:

- Add kill_child option

# 0.4.6 (2016/01/07)

Fixes:

- Object#timeout is deprecated, use Timeout.timeout instead.

# 0.4.5 (2016/01/05)

Fixes:

- Avoid pipe deadlock

# 0.4.4 (2015/11/25)

Fixes:

- Fix not to discard the last argument in dry-run mode print (thanks @niku4i)

# 0.4.3 (2015/09/11)

Enhancements:

- Add :dry_run option

# 0.4.2 (2015/09/11)

yanked

# 0.4.1 (2015/08/15)

Changes:

- :timeout option now raises Frontkick::Timeout

Enhancements:

- Add :timeout_kill => false option not to kill timeouted process

# 0.4.0 (2015/08/15)

yanked

# 0.3.5 (2015/08/13)

Enhancements:

- Enhance compatibility with Open3 Result::Status
  - alias :success? to :successful?
  - alias :exitstatus to :exit_code

# 0.3.4 (2014/07/30)

Enhancements:

- Add `exclusive_blocking` option

# 0.3.3 (2014/06/04)

Changes:

- Rename `Frontkick::CommandResult` to `Frontkick::Result`
- Keep `Frontkick::CommandResult` for lower version compatibility

# 0.3.2 (2014/05/27)

Fixes:

- Fix to require 'frontkick/error'

# 0.3.1 (2014/05/25)

Enhancements:

- Alias `exit_code` to `status`
- Alias `Frontkick::Command.exec` to `Frontkick.exec`

# 0.2.1 (2013/09/13)

Changes:

- Change the internal interface of Frontkick::CommandResult

# 0.2.0 (2013/09/13)

Changes:

- Support exclusive option

# 0.1.0 (2013/06/23)

Changes:

- attr_accessor :exit_code

# 0.0.2 (2013/06/23)

Features:

- Support timeout option

# 0.0.1 (2013/06/23)

First Version

