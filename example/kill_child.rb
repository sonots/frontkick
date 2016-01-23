require 'frontkick'

class SignalHandler
  def self.register
    @pids ||= []
    @main_threads ||= []

    if @signal_pipe_r.nil? and @signal_pipe_w.nil?
      @signal_pipe_r, @signal_pipe_w = IO.pipe
    end

    # For example, loogger `can't be called from trap context`
    trap :INT do
      @signal_pipe_w.puts 'INT'
    end
    trap :TERM do
      @signal_pipe_w.puts 'TERM'
    end

    # Create a new thread to handle signals
    # This example kills child (and self)
    @signal_handler_thr ||= Thread.new do
      begin
        while readable_io = IO.select([@signal_pipe_r])
          signal = readable_io.first[0].gets.strip
          puts "#{signal} signal received"
          @pids.each_with_index do |pid, idx|
            main_thread = @main_threads[idx]
            begin
              puts "kill -#{signal} #{pid}"
              Process.kill(signal, pid) rescue nil
            rescue => e
              main_thread.raise e
            end
          end
          # case signal
          # when 'INT'
          #   Kernel.exit(130)
          # when 'TERM'
          #   Kernel.exit(148)
          # end
        end
      rescue Exception => e
        Thread.main.raise e
      end
    end
  end

  def self.push(pid)
    @pids << pid
    @main_threads << Thread.current
  end

  def self.pop(pid)
    @pids -= [pid]
    @main_threads -= [Thread.current]
  end
end

SignalHandler.register

puts "## Frontkick started"
puts "kill -TERM #{Process.pid} or Hit Ctrl-C in 10 seconds"
result = Frontkick.exec(["sleep 10"]) do |wait_thr|
  begin
    SignalHandler.push(wait_thr.pid)
    puts wait_thr.value # wait child to finish (for normal situation)
  ensure
    SignalHandler.pop(wait_thr.pid)
  end
end

puts "## Fronkick finished"
puts "kill -TERM #{Process.pid} or Hit Ctrl-C in 5 seconds"
sleep 5

puts result.inspect
