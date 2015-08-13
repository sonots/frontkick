module Frontkick
  class Result
    attr_accessor :stdout, :stderr, :exit_code, :duration
    alias :status :exit_code
    alias :status= :exit_code=
    alias :exitstatus :exit_code # for compatibility with Open3 Process::Status
    alias :exitstatus= :exit_code= # for compatibility with Open3 Process::Status

    def initialize(params)
      @stdout = params[:stdout] || ""
      @stderr = params[:stderr] || ""
      @exit_code = params[:exit_code] || 0
      @duration = params[:duration] || 0
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
    alias :success? :successful? # for compatibility with Open3 Process::Status
  end
  CommandResult = Result # for lower version compatibility
end
