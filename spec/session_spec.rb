require 'spec_helper'

describe GitHandler::Session do
  context '.new' do
    it 'requires configuration' do
      proc { GitHandler::Session.new }.should raise_error GitHandler::SessionError
    end

    it 'raises error if home path does not exist' do
      config = GitHandler::Configuration.new(:home_path => '/var/foo')
      proc { GitHandler::Session.new(config) }.
        should raise_error GitHandler::ConfigurationError, "Home path does not exist!"
    end

    it 'raises error if repos path does not exist' do
      config = GitHandler::Configuration.new(:home_path => '/tmp', :repos_path => '/var/foo')
      proc { GitHandler::Session.new(config) }.
        should raise_error GitHandler::ConfigurationError, "Repositories path does not exist!"
    end
  end

  it 'raises error if user is invalid' do
    # TODO
  end

  it 'raises error if environment is invalid' do
    # TODO
  end
end