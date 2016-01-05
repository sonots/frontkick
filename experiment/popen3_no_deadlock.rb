require 'open3'

# popen3 without deadlock version
# almost same with what capture3 does

cmd_array = ['./cat_64k.rb']
stdin, out, err, wait_thr = Open3.popen3(*cmd_array)
out_reader = Thread.new { out.read }
err_reader = Thread.new { err.read }
stdin.close
pid = wait_thr.pid
stdout = out_reader.value
stderr = err_reader.value
exit_code = wait_thr.value.exitstatus

puts 'no deadlock'
