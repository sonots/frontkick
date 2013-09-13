require 'benchmark'
require 'open3'

module Frontkick
  class Locked < StandardError
  end
end

module Frontkick
  class Command
    def self.exec(cmd, opts = {})
      stdout, stderr, exit_code, duration = nil
      stdin, out, err, wait_thr, pid = nil

      cmd_array = cmd.kind_of?(Array) ? cmd : [cmd]
      lock_fd = file_lock(opts[:exclusive]) if opts[:exclusive]
      begin
        timeout(opts[:timeout]) do # nil is for no timeout
          duration = Benchmark.realtime do
            stdin, out, err, wait_thr = Open3.popen3(*cmd_array)
            stdin.close
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
        stdin.close if stdin and !stdin.closed?
        out.close if out and !out.closed?
        err.close if err and !err.closed?
        wait_thr.kill if wait_thr and !wait_thr.stop?
        lock_fd.flock(File::LOCK_UN)
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

    # Use file lock to perfome exclusive operation
    #
    # @param lock_file file path used to lock
    # @return file descriptor
    # @raise Fontkick::Locked if locked
    def self.file_lock(lock_file)
      lock_fd = File.open(lock_file, File::RDWR|File::CREAT, 0644)
      success = lock_fd.flock(File::LOCK_EX|File::LOCK_NB)
      unless success
        lock_fd.flock(File::LOCK_UN)
        raise Frontkick::Locked
      end
      lock_fd
    end
  end
end
