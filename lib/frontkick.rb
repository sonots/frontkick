require 'rubygems'
require 'frontkick/version'
require 'frontkick/error'
require 'frontkick/command'
require 'frontkick/result'

module Frontkick
  def self.exec(cmd, opts = {}, &block)
    ::Frontkick::Command.exec(cmd, opts, &block)
  end

  def self.process_wait(pid)
    ::Frontkick::Command.process_wait(pid)
  end
end
