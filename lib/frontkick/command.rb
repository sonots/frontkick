require 'benchmark'
require 'open3'

module Frontkick
  class Command
    def self.exec(cmd, opts = {})
      stdout, stderr, exit_code, duration = nil
      stdin, out, err, wait_thr, pid = nil

      cmd_array = cmd.kind_of?(Array) ? cmd : [cmd]
      begin
        timeout(opts[:timeout]) do # nil is for no timeout
          duration = Benchmark.realtime do
            stdin, out, err, wait_thr = Open3.popen3(*cmd_array)
            pid = wait_thr.pid
            stdout = out.read
            stderr = err.read
            exit_code = wait_thr.value.exitstatus
            process_wait(pid)
          end
        end
      rescue Timeout::Error => e
        Process.kill('SIGINT', pid)
        exit_code = wait_thr.value.exitstatus
        process_wait(pid)
        duration = opts[:timeout]
        stdout = ""
        stderr = "pid:#{pid}\tcommand:#{cmd_array.join(' ')} is timeout!"
      ensure
        stdin.close unless stdin.nil?
        out.close unless out.nil?
        err.close unless err.nil?
        wait_thr.kill unless wait_thr.stop?
      end
      
      CommandResult.new(stdout, stderr, exit_code, duration)
    end

    def self.process_wait(pid)
      begin
        pid, status = Process.waitpid2(pid) # wait child processes finish
      rescue Errno::ECHILD => e
        # no child process
      end
    end
  end
end
