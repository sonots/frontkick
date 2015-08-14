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

