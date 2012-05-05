require 'spec_helper'

describe GitHandler::Session do
  context '.new' do
    it 'requires configuration' do
      proc { GitHandler::Session.new }.
        should raise_error GitHandler::SessionError, 'Configuration required!'
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

  context '.execute' do
    before :each do
      @config = GitHandler::Configuration.new(
        :home_path  => '/tmp',
        :repos_path => '/tmp'
      )
      @session = GitHandler::Session.new(@config)
      @env = {
        'USER'                 => 'git',
        'HOME'                 => '/tmp',
        'SSH_CLIENT'           => '127.0.0.1',
        'SSH_CONNECTION'       => '127.0.0.1 64039 127.0.0.2 22',
        'SSH_ORIGINAL_COMMAND' => "git-upload-pack 'valid-repo.git'"
      }
    end

    subject do
      GitHandler::Session.new(@config)
    end

    it 'validates environment' do
      proc { subject.execute([], {}) }.
        should raise_error GitHandler::SessionError, 'Invalid environment'

      proc { subject.execute([], {'USER' => 'git', 'HOME' => '/invalid/path'}) }.
        should raise_error GitHandler::SessionError, 'Invalid environment'

      proc { subject.execute([], {'USER' => 'git', 'HOME' => '/tmp'}) }.
        should_not raise_error GitHandler::SessionError, 'Invalid environment'
    end

    it 'validates git request' do
      env = {'USER' => 'git', 'HOME' => '/tmp'}

      proc { subject.execute([], env) }.
        should raise_error GitHandler::SessionError, 'Invalid git request'

      env.merge!(
        'SSH_CLIENT'           => '127.0.0.1',
        'SSH_CONNECTION'       => '127.0.0.1 64039 127.0.0.2 22',
        'SSH_ORIGINAL_COMMAND' => 'foobar'
      )

      proc { subject.execute([], env) }.
        should raise_error GitHandler::SessionError, 'Invalid git request'

      env['SSH_ORIGINAL_COMMAND'] = "git-upload-pack 'foobar.git'"

      proc { subject.execute([], env) }.
        should_not raise_error GitHandler::SessionError, 'Invalid git request'
    end

    it 'validates repository existense' do
      proc { subject.execute([], @env) }.
        should raise_error GitHandler::SessionError, 'Repository valid-repo.git does not exist!'
    end
  end
end