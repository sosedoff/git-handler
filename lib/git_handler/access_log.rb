module GitHandler
  module AccessLog
    def logger
      @logger ||= Logger.new('/tmp/git_handler.log')
    end
    
    def log_transaction
      conn = env['SSH_CONNECTION'].split(' ')
      conn = "#{conn[0]} #{conn[2]}"
      logger.info("Git transaction: #{args.join(' ')} #{conn} #{env['SSH_ORIGINAL_COMMAND']}")
    end
  end
end