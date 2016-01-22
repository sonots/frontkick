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

    result = Frontkick.exec(["echo", "*"], :dry_run => true)
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

### Kill Child Option

On receiving INT and TERM signal, kill the kicked child process before exiting

    Frontkick.exec(["sleep 100"], :kill_child => true)

NOTE: This uses Kernel.trap inside.
NOTE: Shoud use `[]` form, otherwirse `sh -c 'sleep 100'` is ran, and frotkick kills sh process, but sleep process remains

### Spawn Options

Other options such as :chdir are treated as options of `Kernel.#spawn`. See http://ruby-doc.org/core-2.3.0/Kernel.html#method-i-spawn for available options.

### Hint: Redirect stderr to stdout

Frontkick itself does not aid anything, but you can do as

    result = Frontkick.exec(["ls /something_not_found 2>&1"])
    puts result.stdout #=> ls: /something_not_found: No such file or directory

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
