require 'spec_helper'

describe GitHandler::Configuration do
  it 'has default settings' do
    config = GitHandler::Configuration.new
    config.user.should eq('git')
    config.home_path.should eq('/home/git')
    config.repos_path.should eq('/home/git/repositories')
    config.log_path.should eq('/home/git/access.log')
    config.raise_errors.should eq(true)
  end
end