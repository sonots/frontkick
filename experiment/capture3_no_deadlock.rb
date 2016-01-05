require 'open3'

# capture3 handles the deadlock problem of popen3, no deadlock occurs

cmd_array = ['./cat_64k.rb']
stdout, stderr, status = Open3.capture3(*cmd_array, :stdin_data => '')

puts 'no daedlock'
