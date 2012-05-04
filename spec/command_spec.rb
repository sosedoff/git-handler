require 'spec_helper'

class TestInstance
  include GitHandler::GitCommand
end

describe GitHandler::GitCommand do
  before do
    @obj = TestInstance.new
  end

  it 'detects a valid git command' do
    @obj.valid_command?("invalid command").should be_false
    @obj.valid_command?("git-receive-pack").should be_false
    @obj.valid_command?("git-receive-pack repo.git").should be_false
    @obj.valid_command?("git-receive-pack 'repo'").should be_true
    @obj.valid_command?("git-receive-pack 'repo.git'").should be_true
  end

  context '.parse_command' do
    it 'raises error on invalid git command' do
      proc { @obj.parse_command("invalid command") }.
        should raise_error GitHandler::ParseError

      proc { @obj.parse_command("git-receive-pack 'repo.git'") }.
        should_not raise_error GitHandler::ParseError
    end

    it 'returns a proper action and repo' do
      result = @obj.parse_command("git-receive-pack 'repo.git'")
      result.should be_a Hash
      result.should eql(:action => 'git-receive-pack', :repo => 'repo.git')
    end
  end

  it 'detects read command' do
    @obj.read_command?('git-receive-pack').should be_false
    @obj.read_command?('git-upload-pack').should be_true
    @obj.read_command?('git upload-pack').should be_true
    @obj.read_command?('git-upload-archive').should be_true
    @obj.read_command?('git upload-archive').should be_true
  end

  it 'detects write command' do
    @obj.write_command?("git-upload-pack").should be_false
    @obj.write_command?("git-upload-archive").should be_false
    @obj.write_command?("git receive-pack").should be_true
    @obj.write_command?("git-receive-pack").should be_true
  end
end