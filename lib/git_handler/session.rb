require 'logger'

module GitHandler
  class Session
    include GitHandler::GitCommand

    attr_reader :args, :env, :config
    attr_reader :log

    # Initialize a new Session
    # @param [Configuration] config an existing configuration instance
    def initialize(config=nil)
      unless config.kind_of?(GitHandler::Configuration)
        raise SessionError, 'Configuration required!'
      end

      if config.raise_errors == true
        unless File.exists?(config.home_path)
          raise ConfigurationError, "Home path does not exist!"
        end

        unless File.exists?(config.repos_path)
          raise ConfigurationError, "Repositories path does not exist!"
        end
      end

      @config = config
      @log    = Logger.new(@config.log_path)
    end
    
    # Execute session 
    # 
    # @param [Array] args session arguments
    # @param [Hash] env hash with environment variables, use ENV.to_hash.dup
    # @param [Boolean] run_git execute git command if set to true
    def execute(args, env, run_git=true)
      @args = args
      @env  = env

      raise SessionError, "Invalid environment" unless valid_environment?
      raise SessionError, "Invalid git request" unless valid_request?

      command   = parse_command(env['SSH_ORIGINAL_COMMAND'])
      repo_path = File.join(config.repos_path, command[:repo])
      request   = GitHandler::Request.new(
        :remote_ip => env['SSH_CLIENT'].split(' ').first,
        :args      => args,
        :env       => env,
        :repo      => command[:repo],
        :repo_path => repo_path,
        :command   => [command[:action], "'#{repo_path}'"].join(' '),
        :read      => command[:read],
        :write     => command[:write]
      )

      log_request(request)

      if config.raise_errors == true
        unless File.exist?(request.repo_path)
          raise SessionError, "Repository #{request.repo} does not exist!"
        end
      end

      if block_given?
        # Pass all request information for custom processing
        # if no block is defined it will execute git-shell
        # with parameters provided
        yield request
      else
        if run_git == true
          exec("git-shell", "-c", request.command)
        end
      end

      # Interesting part, inspired by github write-up
      # if we need to pass this to another server
      # the process should replace itself with another ssh call:
      # exec("ssh", "git@TARGET", "#{args.join(' ')}")
    end

    # Execute session with catch-all-exceptions wrapper
    # terminates session on SessionError or Exception
    # 
    # @param [Array] args session arguments
    # @param [Hash] env hash with environment variables, use ENV.to_hash.dup
    # @param [Boolean] run_git execute git command if set to true
    def execute_safe(args, env, run_git=true)
      begin
        execute(args, env, run_git)
      rescue GitHandler::SessionError => err
        # TODO: Some additional logging here
        terminate(err.message)
      rescue Exception => err
        # TODO: Needs some love here
        terminate(err.message)
      end
    end

    # Terminate session execution
    # 
    # @param [String] reason
    # @param [Fixnum] exit_status
    def terminate(reason='', exit_status=1)
      logger.error("Session terminated. Reason: #{reason}")
      $stderr.puts("Request failed: #{reason}")
      exit(exit_status)
    end
    
    # Check if session environment is valid
    # @return [Boolean]
    def valid_environment?
      env['USER'] == config.user && env['HOME'] == config.home_path
    end
    
    # Check if session request is valid
    # @return [Boolean]
    def valid_request?
      if env.include_all?(['SSH_CLIENT', 'SSH_CONNECTION', 'SSH_ORIGINAL_COMMAND'])
        if valid_command?(env['SSH_ORIGINAL_COMMAND'])
          return true
        end
      end
      false
    end

    private

    def log_request(req)
      log.info("Request \"#{req.command}\" from #{req.remote_ip}. Args: #{req.args.join(' ')}")
    end
  end
end