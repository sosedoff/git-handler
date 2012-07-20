#!/usr/bin/env ruby
require 'git_handler'

config = GitHandler::Configuration.new

begin
  session = GitHandler::Session.new(config)
  session.execute(ARGV.dup, ENV.dup.to_hash)
rescue Exception => ex
  STDERR.puts "Error: #{ex.message}"
  exit(1)
end