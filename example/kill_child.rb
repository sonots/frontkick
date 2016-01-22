require 'frontkick'

puts Process.pid
result = Frontkick.exec(["sleep 3000"]) do |pid|
  trap :INT do
    Process.kill(:TERM, pid)
    # wait child processes finish
    begin
      pid, status = Process.waitpid2(pid)
    rescue Errno::ECHILD => e
    end
    exit 130
  end
  trap :TERM do
    Process.kill(:TERM, pid)
    Frontkick.process_wait(pid)
    exit 143
  end
end
puts result.stdout
