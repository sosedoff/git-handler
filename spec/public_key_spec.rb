require 'spec_helper'
require 'git_handler/public_key'

describe GitHandler::PublicKey do
  it 'required content' do
    proc { GitHandler::PublicKey.new }.
      should raise_error ArgumentError, 'Key content is empty!'
  end

  it 'should be valid' do
    proc { GitHandler::PublicKey.new('some data') }.
      should raise_error ArgumentError, 'Is not a valid public key!'

    k = SSHKey.generate

    proc { GitHandler::PublicKey.new(k.ssh_public_key) }.
      should_not raise_error ArgumentError, 'Is not a valid public key!'
  end

  context '.to_system_key' do
    it 'returns a customized key content' do
      k = SSHKey.generate
      key = GitHandler::PublicKey.new(k.ssh_public_key)
      custom = key.to_system_key('foobar')
      custom.should eq('command="foobar",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ' + k.ssh_public_key)
    end
  end
end