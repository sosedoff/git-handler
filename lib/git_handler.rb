require 'git_handler/core_ext/array'
require 'git_handler/core_ext/hash'
require 'git_handler/version'
require 'git_handler/errors'
require 'git_handler/configuration'
require 'git_handler/request'
require 'git_handler/git_command'
require 'git_handler/session'

module GitHandler
  # Shorthand for GitHandler::Session.new
  # @param [Configuration] config configuration instance
  # @return [Session] new session instance
  def self.new(config)
    GitHandler::Session.new(config)
  end
end