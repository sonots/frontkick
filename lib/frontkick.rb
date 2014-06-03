require 'rubygems'
require 'frontkick/version'
require 'frontkick/error'
require 'frontkick/command'
require 'frontkick/result'

module Frontkick
  def self.exec(cmd, opts = {})
    ::Frontkick::Command.exec(cmd, opts)
  end
end
