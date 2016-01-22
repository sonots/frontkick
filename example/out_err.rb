require 'frontkick'

out = '/tmp/frontkick_stdout.txt'
err = '/tmp/frontkick_stderr.txt'
result = Frontkick.exec(["ls /something_not_found"], :out => out, :err => err)
puts "write to #{result.stdout} and #{result.stderr}"
puts File.read(result.stdout)
puts File.read(result.stderr)
