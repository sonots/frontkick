module Frontkick
  class CommandResult
    attr_accessor :stdout, :stderr, :duration

    def initialize(stdout, stderr, exit_code, duration)
      @stdout = stdout
      @stderr = stderr
      @exit_code = exit_code
      @duration = duration
    end

    def output
      @stdout
    end

    def errors
      @stderr
    end

    def successful?
      @exit_code == 0
    end
  end
end
