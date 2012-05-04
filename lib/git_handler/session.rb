module GitHandler
  class Session
    include GitHandler::GitCommand
    include GitHandler::AccessLog

    attr_reader :args, :env, :config

    # Initialize a new Session
    # 
    # config - GitHandler::Configuration instance
    #
    def initialize(config=nil)
      unless config.kind_of?(GitHandler::Configuration)
        raise SessionError, 'Configuration required!'
      end

      unless File.exists?(config.home_path)
        raise ConfigurationError, "Home path does not exist!"
      end

      unless File.exists?(config.repos_path)
        raise ConfigurationError, "Repositories path does not exist!"
      end

      @config = config
    end
    
    # Execute session
    #
    # args - Command arguments
    # env - Environment parameters
    #
    def execute(args, env)
      @args = args
      @env  = env

      raise SessionError, "Invalid environment" unless valid_environment?
      raise SessionError, "Git requests only"   unless valid_request?

      command = parse_command(env['SSH_ORIGINAL_COMMAND'])
      repo_path = File.join(config.repositories_path, command[:repo])
      options = [command[:action], repo_path].join(' ')

      exec("git-shell", "-c", options)

      # Interesting part, inspired by github write-up
      # if we need to pass this to another server
      # the process should replace itself with another ssh call:
      # exec("ssh", "git@TARGET", "#{args.join(' ')}")
    end
    
    # Terminate session execution
    # 
    # reason - Process termination reason message
    # exit_status - Exit code (default: 1)
    #
    def terminate(reason='', exit_status=1)
      logger.error("Session terminated. Reason: #{reason}")
      $stderr.puts("Request failed: #{reason}")
      exit(exit_status)
    end
    
    # Check if session environment is valid
    #
    def valid_environment?
      env['USER'] == config.user && env['HOME'] == config.home_path
    end
    
    # Check if session request is valid
    #
    def valid_request?
      if env.key?('SSH_CLIENT') && env.key?('SSH_CONNECTION') && env.key?('SSH_ORIGINAL_COMMAND')
        if valid_command?(env['SSH_ORIGINAL_COMMAND'])
          return true
        end
      end
      false
    end
  end
end