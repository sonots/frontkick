# frontkick [![Build Status](https://secure.travis-ci.org/sonots/frontkick.png?branch=master)](http://travis-ci.org/sonots/frontkick) [![Dependency Status](https://gemnasium.com/sonots/frontkick.png)](https://gemnasium.com/sonots/frontkick)

testing ruby: 1.9.2, 1.9.3, 2.0.0;

Frontkick is a gem to execute a command and obtain exit\_code, stdout, stderr simply. 

## What is This For?

Ruby's `Kernel.#system` method does not return STDOUT and STDERR. 
Ruby's back quote (``) returns STDOUT, but does not return STDERR.

With frontkick, you can easily get the exit code, STDOUT, and STDERR. 

## USAGE

    gem install frontkick

### Basic Usage

    result = Frontkick.exec("echo *")
    puts result.successful? #=> true if exit_code is 0
    puts result.success?    #=> alias to successful?, for compatibility with Process::Status
    puts result.stdout      #=> stdout output of the command
    puts result.stderr      #=> stderr output of the command
    puts result.exit_code   #=> exit_code of the command
    puts result.status      #=> alias to exit_code
    puts result.exitstatus  #=> alias to exit_code, for compatibility with Process::Status
    puts result.duration    #=> the time used to execute the command

### Escape Command

    result = Frontkick.exec(["echo", "*"]) #=> echo the asterisk character

### Dry Run Option

    result = Frontkick.exec(["echo", "*"], :dry_run => 1)
    puts result.stdout #=> echo \*

### Timeout Option

    Frontkick.exec("sleep 2 && ls /hoge", :timeout => 1) # raises Frontkick::Timeout

not to kill timeouted process

    Frontkick.exec("sleep 2 && ls /hoge", :timeout => 1, :timeout_kill => false) # raises Frontkick::Timeout

### Exclusive Option

Prohibit another process to run a command concurrently

    Frontkick.exec("sleep 2 && ls /hoge", :exclusive => "/tmp/frontkick.lock") # raises Fontkick::Locked if locked

If you prefer to be blocked:

    Frontkick.exec("sleep 2 && ls /hoge", :exclusive => "/tmp/frontkick.lock", :exclusive_blocking => true)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
