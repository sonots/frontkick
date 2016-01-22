require 'frontkick'

puts Process.pid
result = Frontkick.exec(["sleep 3000"], :kill_child => true)
puts result.stdout
