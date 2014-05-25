# frontkick [![Build Status](https://secure.travis-ci.org/sonots/frontkick.png?branch=master)](http://travis-ci.org/sonots/frontkick) [![Dependency Status](https://gemnasium.com/sonots/frontkick.png)](https://gemnasium.com/sonots/frontkick)

testing ruby: 1.9.2, 1.9.3, 2.0.0;

Frontkick is a gem to execute a command and obtain exit\_code, stdout, stderr simply, wheres, `system` does not provide all of them.

## USAGE

    gem install frontkick

### Basic Usage

    result = Frontkick.exec("echo *")
    puts result.successful? #=> true if exit_code is 0
    puts result.stdout #=> stdout output of the command
    puts result.stderr #=> stderr output of the command
    puts result.exit_code #=> exit_code of the command
    puts result.duration #=> the time used to execute the command
    puts result.status #=> alias to exit_code

### Escape Command

    result = Frontkick.exec(["echo", "*"]) #=> echo the asterisk character

### Timeout Option

    Frontkick.exec("sleep 2 && ls /hoge", :timeout => 1)

### Exclusive Option

Prohibit another process to run a command concurrently

    Frontkick.exec("sleep 2 && ls /hoge", :exclusive => "/tmp/frontkick.lock") # raises Fontkick::Locked if locked

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
