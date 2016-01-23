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

To kill your frontkick process with its kicked child process, send signal to their signal group as

    kill -TERM -{PGID}

You can find PGID like `ps -eo pid,pgid,command`.

If you can not send a signal to a signal group by some reasons, handle signal by yourself as

```ruby
Frontkick.exec(["sleep 100"]) do |wait_thr|
  pid = wait_thr.pid
  trap :INT do
    Process.kill(:TERM, pid)
    # wait child processes finish
    begin
      pid, status = Process.waitpid2(pid)
    rescue Errno::ECHILD => e
    end
    exit 130
  end
  trap :TERM do
    Process.kill(:TERM, pid)
    Frontkick.process_wait(pid) # same with above
    exit 143
  end
end
```

More sophisticated example is available at [./example/kill_child.rb]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
