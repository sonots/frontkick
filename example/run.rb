require 'frontkick'

result = Frontkick.exec(["#{__dir__}/../experiment/cat_64k.rb"])
puts "exitstatus: #{result.exitstatus}"
puts "stdout: #{result.stdout}"
