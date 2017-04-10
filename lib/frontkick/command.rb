require 'benchmark'
require 'open3'
require 'shellwords'

module Frontkick
  class Command
    def self.exec(*env_cmd, **opts, &block)
      env, cmd = env_cmd.size >= 2 ? env_cmd : [{}, env_cmd.first]
      # With this conversion,
      #
      #   popen3(env, *cmd_array, opts)
      #
      # works for both interface of:
      #
      #   popen3(env, command, opts)
      #   popen3(env, program, *args, opts)
      cmd_array = cmd.is_a?(Array) ? cmd : [cmd]

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

      if opts[:dry_run]
        command = build_command(env, cmd_array)
        return Result.new(:stdout => command, :stderr => '', :exit_code => 0, :duration => 0)
      end

      popen3_opts = self.popen3_opts(opts)

      lock_fd = file_lock(opts[:exclusive], opts[:exclusive_blocking]) if opts[:exclusive]
      begin
        ::Timeout.timeout(opts[:timeout], Frontkick::TimeoutLocal) do # nil is for no timeout
          duration = Benchmark.realtime do
            if opts[:popen2e]
              stdin, stdout, wait_thr = Open3.popen2e(env, *cmd_array, popen3_opts)
              out_thr = Thread.new {
                begin
                  while true
                    out.write stdout.readpartial(4096)
                  end
                rescue EOFError
                end
              }
              stdin.close
              pid = wait_thr.pid

              yield(wait_thr) if block_given?

              out_thr.join
              exit_code = wait_thr.value.exitstatus
              process_wait(pid)
            else
              stdin, stdout, stderr, wait_thr = Open3.popen3(env, *cmd_array, popen3_opts)
              out_thr = Thread.new {
                begin
                  while true
                    out.write stdout.readpartial(4096)
                  end
                rescue EOFError
                end
              }
              err_thr = Thread.new {
                begin
                  while true
                    err.write stderr.readpartial(4096)
                  end
                rescue EOFError
                end
              }
              stdin.close
              pid = wait_thr.pid

              yield(wait_thr) if block_given?

              out_thr.join
              err_thr.join
              exit_code = wait_thr.value.exitstatus
              process_wait(pid)
            end
          end
        end
      rescue Frontkick::TimeoutLocal => e
        if opts[:timeout_kill]
          Process.kill('SIGINT', pid)
          exit_code = wait_thr.value.exitstatus
          process_wait(pid)
        end
        command = build_command(env, cmd_array)
        raise Frontkick::Timeout.new(pid, command, opts[:timeout_kill])
      ensure
        stdin.close if stdin and !stdin.closed?
        stdout.close if stdout and !stdout.closed?
        stderr.close if stderr and !stderr.closed?
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

    def self.build_command(env, cmd_array)
      command = env.map {|k,v| "#{k}=#{v} " }.join('')
      command << cmd_array.first
      command << " #{cmd_array[1..-1].shelljoin}" if cmd_array.size > 1
      command
    end

    def self.popen3_opts(opts)
      opts.dup.tap {|o|
        o.delete(:timeout_kill)
        o.delete(:exclusive)
        o.delete(:exclusive_blocking)
        o.delete(:timeout)
        o.delete(:out)
        o.delete(:err)
        o.delete(:popen2e)
      }
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
