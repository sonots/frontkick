require 'frontkick'

result = Frontkick.exec(["pwd"], :chdir => '/')
puts result.stdout
