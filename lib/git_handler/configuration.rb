module GitHandler
  class Configuration
    # @return [String] Git user name
    attr_reader :user

    # @return [String] Full path to home directory
    attr_reader :home_path

    # @return [String] Full path to repositories directory
    attr_reader :repos_path

    # @return [String] Full path to log file
    attr_reader :log_path

    # @return [Boolean] Log requests
    attr_reader :log

    # @return [Boolean] Raise errors for home and repository path
    attr_reader :raise_errors

    # Initialize a new Configuration instance with options hash
    #
    # Valid options:
    #   :user         - Git user (git)
    #   :home_path    - Git user home path (/home/git)
    #   :repos_path   - Path to repositories (/home/git/repositories)
    #   :log          - Log requests (true)
    #   :log_path     - Git access log path (/home/git/access.log)
    #   :raise_errors - Raise errors (true)
    #
    # @param [Hash] options options hash
    def initialize(options={})
      @user         = options[:user]         || 'git'
      @home_path    = options[:home_path]    || '/home/git'
      @repos_path   = options[:repos_path]   || File.join(@home_path, 'repositories')
      @log_path     = options[:log_path]     || File.join(@home_path, 'access.log')

      @log = true
      @raise_errors = true

      @log = false if options[:log] == false
      @raise_errors = false if options[:raise_errors] == false
    end
  end
end