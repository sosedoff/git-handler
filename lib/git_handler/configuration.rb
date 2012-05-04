module GitHandler
  class Configuration
    attr_reader :user
    attr_reader :home_path
    attr_reader :repos_path
    attr_reader :log_path

    # Initialize a new Configuration instance with options hash
    #
    # Valid options:
    #   :user       - Git user
    #   :home_path  - Git user home path
    #   :repos_path - Path to repositories
    #   :log_path   - Git access log path
    #
    def initialize(options={})
      @user       = options[:user]       || 'git'
      @home_path  = options[:home_path]  || '/home/git'
      @repos_path = options[:repos_path] || '/home/git/repositories'
      @log_path   = options[:log_path]   || '/var/log/git_handler.log'
    end
  end
end