require 'frontkick'

$stdout.sync = true
$stderr.sync = true
result = Frontkick.exec(["#{__dir__}/../experiment/redirect_child.rb"], out: $stdout, err: $stderr)
