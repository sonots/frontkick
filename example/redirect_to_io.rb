require 'frontkick'

$stdout.sync = true
$stderr.sync = true
result = Frontkick.exec(["#{__dir__}/script/print.rb"], out: $stdout, err: $stderr)
