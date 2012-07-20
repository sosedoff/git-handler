module GitHandler
  module AuthorizedKeys
    # Write contents to file with lock
    # @param [String] path path to output file
    # @param [String] content key buffer
    def self.write(path, content)
      raise ArgumentError, "File \"#{path}\" does not exist."  if !File.exists?(path)
      raise ArgumentError, "File \"#{path}\" is not writable." if !File.writable?(path)  

      File.open(path, 'w') do |f|
        f.flock(File::LOCK_EX)
        f.write(content)
        f.flock(File::LOCK_UN)
      end
    end

    # Write formatted keys content to file
    # @param [String] path path to authorized_keys file
    # @param [Array<PublicKey>] keys public keys array
    # @command [String] command custom command for the key
    def self.write_keys(path, keys, command)
      content = keys.map { |k| k.to_system_key(command) }.join("\n").strip
      self.write(path, content)
    end

    # Write a single key formatted content to file
    # @param [String] path path to authorized_keys file
    # @param [PublicKey] keys public key instance
    # @command [String] command custom command for the key
    def self.write_key(path, key, command)
      self.write_keys(path, [key], command)
    end
  end
end