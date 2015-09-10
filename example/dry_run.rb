require 'frontkick'

result = Frontkick.exec(['echo', '*'], :dry_run => 1)
puts result.stdout
