require 'json'
require 'timeout'

module Frontkick
  # ref. http://docs.ruby-lang.org/ja/1.9.3/class/Timeout=3a=3aError.html
  class TimeoutLocal < ::Timeout::Error; end
  class Locked < StandardError; end
  class Timeout < StandardError
    attr_reader :pid, :command, :killed

    def initialize(pid, command, killed)
      @pid = pid
      @command = command
      @killed = killed
    end

    def to_s
      {pid: @pid, command: @command, killed: @killed}.to_json
    end

    alias_method :message, :to_s
  end
end
