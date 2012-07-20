module GitHandler
  module GitCommand
    GIT_COMMAND = /\A(git-upload-pack|git upload-pack|git-upload-archive|git upload-archive|git-receive-pack|git receive-pack) '(.*)'\z/
    GIT_REPO = /\A[a-z\d\-\_\.]{1,128}.git?\z/i

    COMMANDS_READONLY = [
      'git-upload-pack',
      'git upload-pack',
      'git-upload-archive',
      'git upload-archive'
    ]
  
    COMMANDS_WRITE = [
      'git-receive-pack',
      'git receive-pack'
    ]

    # Parse original git command
    # @param [String] cmd git command string
    # @return [Hash] parse result
    def parse_command(cmd)
      unless valid_command?(cmd)
        raise ParseError, "Invalid command: #{cmd}"
      end

      match  = cmd.scan(GIT_COMMAND).flatten
      action = match.first
      repo   = match.last

      unless valid_repository?(repo)
        raise ParseError, "Invalid repository: #{repo}"
      end

      {
        :action => action,
        :repo   => repo,
        :read   => read_command?(action),
        :write  => write_command?(action)
      }
    end
    
    # Check if valid git command
    # @param [String] str command string
    # @return [Boolean]
    def valid_command?(str)
      str =~ GIT_COMMAND ? true : false
    end
    
    # Check if read command
    # @param [String] str command string
    # @return [Boolean]
    def read_command?(str)
      COMMANDS_READONLY.include?(str)
    end
    
    # Check if write command
    # @param [String] str command string
    # @return [Boolean]
    def write_command?(str)
      COMMANDS_WRITE.include?(str)
    end

    # Check if repository name is valid
    # @param [String] name repository name
    # @return [Boolean]
    def valid_repository?(name)
      name =~ GIT_REPO ? true : false
    end
  end
end
