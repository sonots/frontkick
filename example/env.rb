require 'frontkick'

result = Frontkick.exec({'FOO'=>'foo'}, 'env | grep FOO')
puts result.stdout

result = Frontkick.exec({'FOO'=>'foo'}, 'env | grep FOO', {dry_run: true})
puts result.stdout
