module GitHandler
  module AuthorizedKeys
    # Write contents to file with lock
    # 
    # path    - Path to authorized_keys file
    # content - String buffer
    #
    def self.write(path, content)
      raise ArgumentError, "File \"#{path}\" does not exist."  if !File.exists?(path)
      raise ArgumentError, "File \"#{path}\" is not writable." if !File.writable?(path)  

      File.open(path, 'w') do |f|
        f.flock(File::LOCK_EX)
        f.write(content)
        f.flock(File::LOCK_UN)
      end
    end

    # Write formatted keys content to authorized_keys file
    #
    # path    - Path to authorized_keys file
    # keys    - Array of GitHandler::PublicKey instances
    # command - A custom command for the key
    #
    def self.write_keys(path, keys, command)
      content = keys.map { |k| k.to_system_key(command) }.join("\n").strip
      self.write(path, content)
    end
  end
end