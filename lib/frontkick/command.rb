require 'benchmark'
require 'open3'

module FrontKick
  class Command
    def self.exec(*cmd)
      stdout = nil
      stderr = nil
      exit_code = nil 

      duration = Benchmark.realtime do
        Open3.popen3(*cmd) do |stdin, out, err, wait_thr|
          stdout = out.read
          stderr = err.read
          exit_code = wait_thr.value.exitstatus
        end
      end
      
      CommandResult.new(stdout, stderr, exit_code, duration)
    end
  end
end
