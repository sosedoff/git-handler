require 'spec_helper'

class TestInstance
  include GitHandler::GitCommand
end

describe GitHandler::GitCommand do
  let(:command) { TestInstance.new }

  it 'detects a valid git command' do
    command.valid_command?("invalid command").should be_false
    command.valid_command?("line1\nline2").should be_false
    command.valid_command?("git-receive-pack").should be_false
    command.valid_command?("git-receive-pack repo.git").should be_false
    command.valid_command?("git-receive-pack 'repo'").should be_true
    command.valid_command?("git-receive-pack 'repo.git'").should be_true
    command.valid_command?("git-receive-pack 'repo'\ngit-upload-pack 'repo'").should be_false
  end

  it 'detects a valid git repository' do
    command.valid_repository?('repo.git').should be_true
    command.valid_repository?('repo123456.git').should be_true
    command.valid_repository?('repo-name.git').should be_true
    command.valid_repository?('repo_name.git').should be_true
    command.valid_repository?('repo.name.git').should be_true
    command.valid_repository?('repo.name.git.git').should be_true

    command.valid_repository?('repo').should be_false
    command.valid_repository?("repo\nname.git").should be_false
    command.valid_repository?("repo&.name.git").should be_false
  end

  it 'detects read command' do
    command.read_command?('git-receive-pack').should be_false
    command.read_command?('git-upload-pack').should be_true
    command.read_command?('git upload-pack').should be_true
    command.read_command?('git-upload-archive').should be_true
    command.read_command?('git upload-archive').should be_true
  end

  it 'detects write command' do
    command.write_command?("git-upload-pack").should be_false
    command.write_command?("git-upload-archive").should be_false
    command.write_command?("git receive-pack").should be_true
    command.write_command?("git-receive-pack").should be_true
  end

  context '.parse_command' do
    it 'raises error on invalid git command' do
      proc { command.parse_command("invalid command") }.
        should raise_error GitHandler::ParseError

      proc { command.parse_command("git-receive-pack 'repo.git'") }.
        should_not raise_error GitHandler::ParseError
    end

    it 'raises an error on invalid repository name' do
      proc { command.parse_command("git-receive-pack 'invalid-repo'") }.
        should raise_error GitHandler::ParseError, "Invalid repository: invalid-repo"
    end

    it 'returns a proper action and repo' do
      result = command.parse_command("git-receive-pack 'repo.git'")
      result.should be_a Hash
      result.should eql(
        :action => 'git-receive-pack', 
        :repo   => 'repo.git',
        :read   => false,
        :write  => true
      )
    end
  end
end