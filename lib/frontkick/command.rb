require 'benchmark'
require 'open3'
require 'shellwords'

module Frontkick
  class Command
    def self.exec(cmd, opts = {})
      opts[:timeout_kill] = true unless opts.has_key?(:timeout_kill) # default: true

      exit_code, duration = nil
      stdin, stdout, stderr, wait_thr, pid = nil

      if opts[:out]
        if opts[:out].is_a?(String)
          out = File.open(opts[:out], 'w')
          out.sync = true
        else
          out = opts[:out] # IO
        end
      else
        out = StringIO.new
      end

      if opts[:err]
        if opts[:err].is_a?(String)
          err = File.open(opts[:err], 'w')
          err.sync = true
        else
          err = opts[:err] # IO
        end
      else
        err = StringIO.new
      end

      cmd_array = cmd.kind_of?(Array) ? cmd : [cmd]
      command = "#{cmd_array.first} #{Shellwords.shelljoin(cmd_array[1..-1])}"

      if opts[:dry_run]
        return Result.new(:stdout => command, :stderr => '', :exit_code => 0, :duration => 0)
      end

      spawn_opts = self.spawn_opts(opts)

      lock_fd = file_lock(opts[:exclusive], opts[:exclusive_blocking]) if opts[:exclusive]
      begin
        ::Timeout.timeout(opts[:timeout], Frontkick::TimeoutLocal) do # nil is for no timeout
          duration = Benchmark.realtime do
            stdin, stdout, stderr, wait_thr = Open3.popen3(*cmd_array, spawn_opts)
            out_thread = Thread.new {
              begin
                while true
                  out.write stdout.readpartial(4096)
                end
              rescue EOFError
              end
            }
            err_thread = Thread.new {
              begin
                while true
                  err.write stderr.readpartial(4096)
                end
              rescue EOFError
              end
            }
            stdin.close
            pid = wait_thr.pid

            if opts[:kill_child]
              trap_signal(pid)
            end

            out_thread.join
            err_thread.join
            exit_code = wait_thr.value.exitstatus
            process_wait(pid)
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
        if opts[:out] and opts[:out].is_a?(String)
          out.close rescue nil
        end
        if opts[:err] and opts[:err].is_a?(String)
          err.close rescue nil
        end
      end

      Result.new(
        :stdout => opts[:out] ? opts[:out] : out.string,
        :stderr => opts[:err] ? opts[:err] : err.string,
        :exit_code => exit_code, :duration => duration
      )
    end

    # private

    def self.spawn_opts(opts)
      opts.dup.tap {|o|
        o.delete(:timeout_kill)
        o.delete(:exclusive)
        o.delete(:exclusive_blocking)
        o.delete(:timeout)
        o.delete(:kill_child)
      }
    end

    def self.trap_signal(pid)
      trap :INT do
        Process.kill(:TERM, pid)
        process_wait(pid)
        exit 130
      end
      trap :TERM do
        Process.kill(:TERM, pid)
        process_wait(pid)
        exit 143
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
