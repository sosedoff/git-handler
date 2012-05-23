require 'spec_helper'
require 'fileutils'
require 'git_handler/authorized_keys'

describe GitHandler::AuthorizedKeys do
  before :each do
    @path = '/tmp/authorized_keys'
    File.delete(@path) if File.exists?(@path)
  end

  after :each do
    File.delete(@path) if File.exists?(@path) 
  end

  describe '.write' do
    it 'raises error if output file does not exist' do
      proc { GitHandler::AuthorizedKeys.write(@path, 'data') }.
        should raise_error ArgumentError, "File \"#{@path}\" does not exist."
    end

    it 'raises error if output file is not writable' do
      FileUtils.touch(@path)
      FileUtils.chmod(0400, @path)

      proc { GitHandler::AuthorizedKeys.write(@path, 'data') }.
        should raise_error ArgumentError, "File \"#{@path}\" is not writable."
    end

    it 'writes data to the output file' do
      FileUtils.touch(@path)
      proc { GitHandler::AuthorizedKeys.write(@path, 'data') }.should_not raise_error
      File.read(@path).should eq("data")
    end
  end

  describe '.write_keys' do
    it 'writes formatted keys content into the output file' do
      FileUtils.touch(@path)
      k = SSHKey.generate
      key = GitHandler::PublicKey.new(k.ssh_public_key)
      GitHandler::AuthorizedKeys.write_keys(@path, [key], 'custom_command')
      File.read(@path).should eq('command="custom_command",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ' + k.ssh_public_key)
    end
  end
end