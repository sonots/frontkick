require 'rubygems'
require 'frontkick/command'
require 'frontkick/command_result'

module Frontkick
  def exec(cmd, opts = {})
    ::Frontkick::Command.exec(cmd, opts)
  end
  module_function :exec
end
