require 'benchmark'
require 'open3'
require 'shellwords'

module Frontkick
  class Command
    def self.exec(cmd, opts = {})
      opts[:timeout_kill] = true unless opts.has_key?(:timeout_kill) # default: true

      stdout, stderr, exit_code, duration = nil
      stdin, out, err, wait_thr, pid = nil

      cmd_array = cmd.kind_of?(Array) ? cmd : [cmd]
      command = "#{cmd_array.first} #{Shellwords.shelljoin(cmd_array[1..-1])}"

      if opts[:dry_run]
        return Result.new(:stdout => command, :stderr => '', :exit_code => 0, :duration => 0)
      end

      lock_fd = file_lock(opts[:exclusive], opts[:exclusive_blocking]) if opts[:exclusive]
      begin
        ::Timeout.timeout(opts[:timeout], Frontkick::TimeoutLocal) do # nil is for no timeout
          duration = Benchmark.realtime do
            stdin, out, err, wait_thr = Open3.popen3(*cmd_array)
            out_reader = Thread.new { out.read }
            err_reader = Thread.new { err.read }
            stdin.close
            pid = wait_thr.pid

            trapped_signal = nil
            if opts[:kill_child]
              trap_signal(pid) {|sig| trapped_signal = sig }
            end

            stdout = out_reader.value
            stderr = err_reader.value
            exit_code = wait_thr.value.exitstatus
            process_wait(pid)

            exit_signal(trapped_signal) if trapped_signal
          end
        end
      rescue Frontkick::TimeoutLocal => e
        if opts[:timeout_kill]
          Process.kill('SIGINT', pid)
          exit_code = wait_thr.value.exitstatus
          process_wait(pid)
        end
        raise Frontkick::Timeout.new(pid, command, opts[:timeout_kill])
      ensure
        stdin.close if stdin and !stdin.closed?
        out.close if out and !out.closed?
        err.close if err and !err.closed?
        wait_thr.kill if wait_thr and !wait_thr.stop?
        lock_fd.flock(File::LOCK_UN) if lock_fd
      end
      
      Result.new(:stdout => stdout, :stderr => stderr, :exit_code => exit_code, :duration => duration)
    end

    def self.trap_signal(pid)
      trap :INT do
        Process.kill(:INT, pid)
        yield(:INT)
      end
      trap :TERM do
        Process.kill(:TERM, pid)
        yield(:TERM)
      end
    end

    def self.exit_signal(signal)
      case signal
      when :INT
        exit(130)
      when :TERM
        exit(143)
      else
        raise 'Non supported signal'
      end
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
    # @param blocking blocking or non-blocking. default is nil (false)
    # @return file descriptor
    # @raise Fontkick::Locked if locked
    def self.file_lock(lock_file, blocking = nil)
      lock_fd = File.open(lock_file, File::RDWR|File::CREAT, 0644)
      if blocking
        lock_fd.flock(File::LOCK_EX)
      else
        success = lock_fd.flock(File::LOCK_EX|File::LOCK_NB)
        unless success
          lock_fd.flock(File::LOCK_UN)
          raise Frontkick::Locked
        end
      end
      lock_fd
    end
  end
end
