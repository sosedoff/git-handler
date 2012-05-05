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
        'SSH_ORIGINAL_COMMAND' => 'invalid command'
      )

      proc { subject.execute([], env, false) }.
        should raise_error GitHandler::SessionError, 'Invalid git request'

      env['SSH_ORIGINAL_COMMAND'] = "git-upload-pack 'foobar.git'"

      proc { subject.execute([], env, false) }.
        should_not raise_error GitHandler::SessionError, 'Invalid git request'
    end

    it 'validates repository existense' do
      @env['SSH_ORIGINAL_COMMAND'] = "git-upload-pack 'invalid-repo.git'"
      proc { subject.execute([], @env, false) }.
        should raise_error GitHandler::SessionError, 'Repository invalid-repo.git does not exist!'

      @env['SSH_ORIGINAL_COMMAND'] = "git-upload-pack 'valid-repo.git'"
      proc { subject.execute([], @env, false) }.
        should_not raise_error GitHandler::SessionError, 'Repository valid-repo.git does not exist!'
    end

    it 'yields request payload if block provided' do
      payload = nil
      subject.execute([], @env, false) { |req| payload = req }
      payload.should_not be_nil
      payload.should be_a GitHandler::Request
      payload.env.should eq(@env)
      payload.repo.should eq('valid-repo.git')
      payload.repo_path.should eq('/tmp/valid-repo.git')
      payload.command.should eq("git-upload-pack '/tmp/valid-repo.git'")
    end
  end
end