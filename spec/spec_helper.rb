$:.unshift File.expand_path("../..", __FILE__)

require 'lib/git_handler'
require 'simplecov'

SimpleCov.start do
  add_group 'GitHandler', 'lib/git_handler'
end