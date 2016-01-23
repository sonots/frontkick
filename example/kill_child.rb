require 'frontkick'

puts "kill -TERM #{Process.pid} or Hit Ctrl-C in 10 seconds"

result = Frontkick.exec(["sleep 10"]) do |wait_thr|
  pid = wait_thr.pid
  signal_pipe_r, signal_pipe_w = IO.pipe

  # You know, there are many things `can't be called from trap context`
  trap :INT do
    signal_pipe_w.puts 'INT'
  end
  trap :TERM do
    signal_pipe_w.puts 'TERM'
  end

  # Create a new thread to handle signals
  # This example kills child and self
  signal_handler_thr = Thread.new do
    readable_io = IO.select([signal_pipe_r])
    signal = readable_io.first[0].gets.strip
    case signal
    when 'INT'
      puts "kill -INT #{pid}"
      Process.kill('INT', pid) rescue nil
      pid, status = Process.waitpid2(pid) rescue nil
      Kernel.exit(130)
    when 'TERM'
      puts "kill -TERM #{pid}"
      Process.kill('TERM', pid) rescue nil
      pid, status = Process.waitpid2(pid) rescue nil
      Kernel.exit(148)
    end
  end

  begin
    # Wait child to finish (for normal situation)
    wait_thr.join

    # Send NOOP to finish signal_handler_thr (for normal situation)
    signal_pipe_w.puts 'NOOP'
    signal_handler_thr.join
  ensure
    signal_pipe_r.close rescue nil
    signal_pipe_w.close rescue nil
  end
end

# should come here if child process finished normally,
# but not come here if signals are received (Kernel.exit)
puts result.inspect
