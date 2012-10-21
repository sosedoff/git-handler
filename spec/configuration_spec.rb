require 'spec_helper'

describe GitHandler::Configuration do
  it 'has default settings' do
    config = GitHandler::Configuration.new
    config.user.should eq('git')
    config.home_path.should eq('/home/git')
    config.repos_path.should eq('/home/git/repositories')
    config.log_path.should eq('/home/git/access.log')
    config.raise_errors.should be_true
    config.log.should be_true
  end

  it 'should disable error checks' do
    config = GitHandler::Configuration.new(:raise_errors => false)
    config.raise_errors.should be_false
  end

  it 'should disable logger' do
    config = GitHandler::Configuration.new(:log => false)
    config.log.should be_false
  end
end