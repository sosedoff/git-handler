# GitHandler [![Build Status](https://secure.travis-ci.org/sosedoff/git-handler.png?branch=master)](http://travis-ci.org/sosedoff/git-handler)

A tool to simplify your git flow customizations. Its main purpose is to provide an
application-based control layer for Git request processing.

## Installation

Install using rubygems:

```
gem install git_handler
```

Or using latest source code:

```
git clone git://github.com/sosedoff/git-handler.git
cd git-handler
bundle install
rake install
```

## Usage

If you already have an operation system configured, make sure you have ```git```
user in your system. In order to use git_handler you'll need to generate a customized SSH public key and 
add it to ```~/.ssh/authorized_keys``` on server. Generation should be something 
that needs to be implemented in your application or script, there is functionality already
built for that:

```ruby
require 'git_handler/public_key'

# Load your current pub key
content = File.read(File.expand_path('~/.ssh/id_rsa.pub'))

# Create a key
key = GitHandler::PublicKey.new(content)
```

Now, to convert loaded key into a system key just run:

```ruby
key.to_system_key('/usr/bin/git_proxy')
# => command="/usr/bin/git_proxy",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNjN3ZUOoosWeuJ7KczE5FAOzwZ+Z51KSQvqTCb7ccBi4u+pPYcGEYr2t0cx/BUcx/ZGE8ih+zxN1qM8KmM0uluuy54itHsKFdAwoibkbG22fQc2DY0RmktXXB/w6LxmFuQrmz0fkcbkE39pm5k6Nw6mqks5HjM7aDXRdwM8fSrq0PjfUNiESIrIAeEMGhtZFaj+WZVMfXaIlgzxZsAUpUULhN4j069v8VgxWyyOUT+gwcQB8lVc0BVYhptlFaJBtwhfWvOAviSuK7Cpjh60NdkZ3R2QYeh6wb6fF+KGCkM4iED4PZ1Ep8fRzrbCHky4VHSOyOvg9qKcgP1h+e+diD 
```

SSH public key is now ready for usage on server side. Drop it into ```~/home/git/.ssh/authorized_keys``` file
if your user is ```git```. The whole purpose of key modifications is that we're 
restricting SSH to a specific command or script on server, which gives us ability
to control permissions and other restrictions.

### Control script

In the example above as you can see we specify ```/usr/bin/git_proxy``` to be 
executed once SSH connection is being established. GitHandler provides a simple
api to verify and execute git request that comes from client. 

Example of ```/usr/bin/git_proxy``` file:

```ruby
#!/usr/bin/env ruby
require 'git_handler'

config = GitHandler::Configuration.new

# Configuration has a bunch of options:
# :user       - Git user, default: git
# :home_path  - Home path, default: /home/git
# :repos_path - Path to repositories, default: /home/git/repositories
# :log_path   - Git requests logger, default: /var/log/git_handler.log

begin
  session = GitHandler::Session.new(config)
  session.execute(ARGV, ENV)
rescue Exception => ex
  STDERR.puts "Error: #{ex.message}"
  exit(1)
end
```

**NOTE:** Script must have permissions for execution.

Session instance will check if incoming git request has a valid environment and 
valid git command. After check is complete it will shell out to ```git-shell -c COMMAND```
to perform an original git command. Providing block to ```session.execute``` will 
override default and allow you to control the logic:

```ruby
session.execute(ARGV, ENV) do |request|

  # Yields GitHandler::Request instance that
  # contains all information about git request, env and repo

  STDERR.puts "-----------------------------"
  STDERR.puts "REMOTE IP: #{request.remote_ip}"
  STDERR.puts "ARGS: #{request.args.inspect}"
  STDERR.puts "ENV: #{request.env.inspect}"
  STDERR.puts "REPO: #{request.repo}"
  STDERR.puts "REPO PATH: #{request.repo_path}"
  STDERR.puts "COMMAND: #{request.command}"
  STDERR.puts "-----------------------------"
end
```

By default, if request has invalid environment attributes or not a git request,
session raises ```GitHandler::SessionError```. If you dont want to handle exceptions,
just use ```session.execute_safe``` method:

```ruby
session = GitHandler::Session.new(config)
session.execute_safe(ARGV, ENV)
```

To test if all that works try this:

```
ssh -vT git@YOUR_HOST.com
```

In the debug output you'll something similar:

```
debug1: Remote: Agent forwarding disabled.
debug1: Remote: Pty allocation disabled.
debug1: Remote: Forced command.
debug1: Remote: Port forwarding disabled.
debug1: Remote: X11 forwarding disabled.
debug1: Remote: Agent forwarding disabled.
debug1: Remote: Pty allocation disabled.
debug1: Sending environment.
debug1: Sending env LANG = en_US.UTF-8

>>> Error: Invalid git request <<<<

debug1: client_input_channel_req: channel 0 rtype exit-status reply 0
debug1: client_input_channel_req: channel 0 rtype eow@openssh.com reply 0
debug1: channel 0: free: client-session, nchannels 1
Transferred: sent 2384, received 2880 bytes, in 0.3 seconds
Bytes per second: sent 7308.1, received 8828.6
debug1: Exit status 1
```

This means that everything works. Script does not provide any shell access and
only allows git requests. To test that, create an empty repository:

```
mkdir /home/git/repositories
cd /home/git/repositories
git init --bare testrepo.git
```

And clone it (on local machine):

```
git clone git@YOUR_HOST.com:testrepo.git
```

### Server side configuration

In case you dont have a git user on your server, here is a quick manual
on how to get it rolling.

Create a git user:

```bash
adduser --home /home/git --disabled-password git
```

Restrict SSH authentication only via public keys. Open file ```/etc/ssh/sshd_config``` and 
add this snippet to the end:

```
Match User !root
  PasswordAuthentication no
```

This will disable password authentications for everyone except root, or other user
of your choice. You'll need to restart ssh daemon:

```
/etc/init.d/ssh restart
```

## Testing

To run the test suite just type:

```
rake test
```

## License

Copyright (c) 2012 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.