require 'open3'

# popen3 blocks if pipe buffer size overs 64k (depends on system, this is on my Mac)
# the child process waits its buffer to be read, but the parent process waits the child
# process finishes and returns EOF, hence deadlocks

cmd_array = ['./cat_64k.rb']
stdin, out, err, wait_thr = Open3.popen3(*cmd_array)
stdin.close
pid = wait_thr.pid
stdout = out.read
stderr = err.read
exit_code = wait_thr.value.exitstatus

puts 'no deadlock'
