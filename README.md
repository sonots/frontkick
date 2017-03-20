# frontkick [![Build Status](https://secure.travis-ci.org/sonots/frontkick.png?branch=master)](http://travis-ci.org/sonots/frontkick) [![Dependency Status](https://gemnasium.com/sonots/frontkick.png)](https://gemnasium.com/sonots/frontkick)

Frontkick is a gem to execute a command and obtain exit\_code, stdout, stderr simply.

## What is This For?

Ruby's `Kernel.#system` method does not return STDOUT and STDERR.
Ruby's back quote (``) returns STDOUT, but does not return STDERR.

With frontkick, you can easily get the exit code, STDOUT, and STDERR.

## USAGE

```
gem install frontkick
```

### Basic Usage

```ruby
result = Frontkick.exec("echo *")
puts result.successful? #=> true if exit_code is 0
puts result.success?    #=> alias to successful?, for compatibility with Process::Status
puts result.stdout      #=> stdout output of the command
puts result.stderr      #=> stderr output of the command
puts result.exit_code   #=> exit_code of the command
puts result.status      #=> alias to exit_code
puts result.exitstatus  #=> alias to exit_code, for compatibility with Process::Status
puts result.duration    #=> the time used to execute the command
```

### No Shell

**String argument**

When the first argument is a String, the command is executed via shell if the command string includes meta characters of shell such as:

```
* ? {} [] <> () ~ & | \ $ ; ' ` " \n
```

otherwise, the command is not executed via shell.

```ruby
result = Frontkick.exec("echo foo") # no shell
result = Frontkick.exec("echo *") # with shell
```

The process tree for the latter (with shell)  will be like:

```
ruby
└─ sh -c
    └── echo *
```

**Array argument**

When the first argument is an Array, The command is not executed via a shell.
Note that shell wildcards are not available with this way.

```ruby
result = Frontkick.exec(["echo", "*"]) #=> echo the asterisk character
```

The process tree will be like:

```
ruby
└─ echo
```

NOTE: This interface is different with Kernel.spawn or Open3.popen3, but similar to IO.popen. Kernel.spawn or Open3.popen3 works with no shell if multiple arguments are given:

```
spawn('echo', '*')
```

IO.popen works with no shell if an array argument is given:

```
IO.popen(['echo', '*'])
```

### Environment Variables

You can pass environment variables as a hash for the 1st argument as [spawn](https://ruby-doc.org/core-2.4.0/Kernel.html#method-i-spawn).

```ruby
result = Frontkick.exec({"FOO"=>"BAR"}, ["echo", "*"])
```

### Dry Run Option

```ruby
result = Frontkick.exec(["echo", "*"], :dry_run => true)
puts result.stdout #=> echo \*
```

### Timeout Option

```ruby
Frontkick.exec("sleep 2 && ls /hoge", :timeout => 1) # raises Frontkick::Timeout
```

not to kill timeouted process

```ruby
Frontkick.exec("sleep 2 && ls /hoge", :timeout => 1, :timeout_kill => false) # raises Frontkick::Timeout
```

### Exclusive Option

Prohibit another process to run a command concurrently

```ruby
Frontkick.exec("sleep 2 && ls /hoge", :exclusive => "/tmp/frontkick.lock") # raises Fontkick::Locked if locked
```

If you prefer to be blocked:

```ruby
Frontkick.exec("sleep 2 && ls /hoge", :exclusive => "/tmp/frontkick.lock", :exclusive_blocking => true)
```

### Redirect Options (:out and :err)

```ruby
Frontkick.exec(["ls /something_not_found"], :out => 'stdout.txt', :err => 'stderr.txt')
```

This redirects STDOUT and STDERR into files. In this case, result.stdout, and result.stderr are the given filename.

```ruby
out = File.open('stdout.txt', 'w').tap {|fp| fp.sync = true }
err = File.open('stderr.txt', 'w').tap {|fp| fp.sync = true }
Frontkick.exec(["ls /something_not_found"], :out => out, :err => err)
```

You can also give IO objects. In this case, result.stdout, and result.stderr are the given IO objects.

### Popen2e Option (Get stdout and stderr together)

```ruby
result = Frontkick.exec("echo foo; ls /something_not_found", :popen2e => true)
puts result.output #=>
foo
ls: /something_not_found: No such file or directory
```

### Popen3 Options (such as :chdir)

Other options such as :chdir are treated as options of `Open3.#popen3`.

### Kill Child Process

Although sending a signal to a kicked child process directly causes no problem (frontkick process can take care of it),
sending a signal to a frontkick process may cause a problem that a child process becomes an orphan process.

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
