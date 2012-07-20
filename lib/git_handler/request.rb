require 'ostruct'

module GitHandler
  class Request
    # @return [String] Remote IP address
    attr_reader :remote_ip

    # @return [Array] Request arguments
    attr_reader :args

    # @return [Hash] Request environment
    attr_reader :env

    # @return [String] Git command
    attr_reader :command

    # @return [Boolean] Read command flag
    attr_reader :read

    # @return [Boolean] Write command flag
    attr_reader :write

    # @return [Boolean] Git repository name
    attr_reader :repo

    # @return [String] Repository path
    attr_reader :repo_path

    # Initialize a new Request instance
    # @param [Hash] options request options
    def initialize(options={})
      @remote_ip = options[:remote_ip]
      @args      = options[:args]
      @env       = options[:env]
      @command   = options[:command]
      @read      = options[:read]
      @write     = options[:write]
      @repo      = options[:repo]
      @repo_path = options[:repo_path]
    end
  end
end