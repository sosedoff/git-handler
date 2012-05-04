module GitHandler
  module GitCommand
    GIT_COMMAND = /^(git-upload-pack|git upload-pack|git-upload-archive|git upload-archive|git-receive-pack|git receive-pack) '(.*)'$/

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

    def parse_command(cmd)
      unless valid_command?(cmd)
        raise ParseError, "Invalid command: #{cmd}"
      end
      match = cmd.scan(GIT_COMMAND).flatten
      {:action => match.first, :repo => match.last}
    end
    
    def valid_command?(cmd)
      cmd =~ GIT_COMMAND ? true : false
    end
    
    def read_command?(cmd)
      COMMANDS_READONLY.include?(cmd)
    end
    
    def write_command?(cmd)
      COMMANDS_WRITE.include?(cmd)
    end
  end
end