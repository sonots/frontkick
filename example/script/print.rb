#!/usr/bin/env ruby
$stdout.sync = true

5.times do |i|
  $stdout.puts 'a' * 10
  sleep 1
end
