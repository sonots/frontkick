require 'rubygems'
require 'frontkick/command'
require 'frontkick/command_result'

module Frontkick
  def self.exec(cmd, opts = {})
    ::Frontkick::Command.exec(cmd, opts)
  end
end
