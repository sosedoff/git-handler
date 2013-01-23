#!/usr/bin/env ruby
require 'git_handler'

config = GitHandler::Configuration.new

begin
  session = GitHandler::Session.new(config)
  session.execute(ARGV.dup, ENV.dup.to_hash) do |req|
    unless req.read
      STDERR.puts "Readonly"
      exit 1
    end
  end

  # Now, replace current process with git shell
  exec('git-shell', '-c', req.command)
rescue Exception => ex
  STDERR.puts "Error: #{ex.message}"
  exit(1)
end