# frontkick [![Build Status](https://secure.travis-ci.org/sonots/frontkick.png?branch=master)](http://travis-ci.org/sonots/frontkick) [![Dependency Status](https://gemnasium.com/sonots/frontkick.png)](https://gemnasium.com/sonots/frontkick)

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

### Redirect Options (:out and :err)

    Frontkick.exec(["ls /something_not_found"], :out => 'stdout.txt', :err => 'stderr.txt')

This redirects STDOUT and STDERR into files. In this case, result.stdout, and result.stderr are the given filename.

    out = File.open('stdout.txt', 'w').tap {|fp| fp.sync = true }
    err = File.open('stderr.txt', 'w').tap {|fp| fp.sync = true }
    Frontkick.exec(["ls /something_not_found"], :out => out, :err => err)

You can also give IO objects. In this case, result.stdout, and result.stderr are the given IO objects.

### Popen3 Options (such as :chdir)

Other options such as :chdir are treated as options of `Open3.#popen3`.

### Kill Child Process

Sending a signal to a kicked child process is fine because a frontkick process can finish.
But, sending a signal to a frontkick process is not fine because a child process would become an orphan process.

To kill your frontkick process with its child process correctly, send a signal to their **process group** as

    kill -TERM -{PGID}

You can find PGID like `ps -eo pid,pgid,command`.

If you can not take such an approach by some reasons (for example, `daemontools`, a process management tool,
does not support to send a signal to a process group), handle signal by yourself as

```ruby
Frontkick.exec(["sleep 100"]) do |wait_thr|
  pid = wait_thr.pid
  trap :INT do
    Process.kill(:TERM, pid)
    exit 130
  end
  trap :TERM do
    Process.kill(:TERM, pid)
    exit 143
  end
end
```

More sophisticated example is available at [./example/kill_child.rb](./example/kill_child.rb)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
