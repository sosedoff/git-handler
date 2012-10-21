module GitHandler
  module AuthorizedKeys
    # Write formatted keys content to file
    # @param path [String] path path to authorized_keys file
    # @param keys [Array<PublicKey>] public key objects
    # @param command [String] custom command for the key
    def self.write_keys(path, keys, command)
      content = keys.map { |k| k.to_system_key(command) }.join("\n").strip
      self.write(path, content)
    end

    # Write a single key formatted content to file
    # @param path [String] authorized keys file path
    # @param key [PublicKey] public key object
    # @param command [String] custom command for the key
    def self.write_key(path, key, command)
      self.write_keys(path, [key], command)
    end

    protected

    # Write contents to file with lock
    # @param path [String] output file path
    # @param content [String] key content
    def self.write(path, content)
      raise ArgumentError, "File \"#{path}\" does not exist."  if !File.exists?(path)
      raise ArgumentError, "File \"#{path}\" is not writable." if !File.writable?(path)  

      File.open(path, 'w') do |f|
        f.flock(File::LOCK_EX)
        f.write(content)
        f.flock(File::LOCK_UN)
      end
    end
  end
end