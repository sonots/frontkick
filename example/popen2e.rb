require 'frontkick'

result = Frontkick.exec(["pwd; ls /something_not_found"], :chdir => '/', :popen2e => true)
puts result.output
