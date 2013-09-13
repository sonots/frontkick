# frontkick [![Build Status](https://secure.travis-ci.org/sonots/frontkick.png?branch=master)](http://travis-ci.org/sonots/frontkick) [![Dependency Status](https://gemnasium.com/sonots/frontkick.png)](https://gemnasium.com/sonots/frontkick)

testing ruby: 1.9.2, 1.9.3, 2.0.0;

Frontkick is a gem to execute a command simply. This is a wrapper of Open3#popen3. 

## USAGE

    gem install frontkick

### Basic Usage

    result = Frontkick::Command.exec("echo *")
    puts result.successful? #=> true if exit_code is 0
    puts result.stdout #=> stdout output of the command
    puts result.stderr #=> stderr output of the command
    puts result.exit_code #=> exit_code of the command
    puts result.duration #=> the time used to execute the command

### Escape Command

    result = Frontkick::Command.exec(["echo", "*"]) #=> echo the asterisk character

### Timeout Option

    Frontkick::Command.exec("sleep 2 && ls /hoge", :timeout => 1)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
