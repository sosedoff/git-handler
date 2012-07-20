require 'digest'
require 'sshkey'

module GitHandler
  class PublicKey
    COMMAND_OPTIONS = [
      'no-port-forwarding',
      'no-X11-forwarding',
      'no-agent-forwarding',
      'no-pty'
    ]

    attr_reader :content

    def initialize(content=nil)
      @content = cleanup_content(content)
      if @content.empty?
        raise ArgumentError, 'Key content is empty!'
      end
      unless valid?
        raise ArgumentError, "Is not a valid public key!"
      end
    end

    # Check if public key contents is valid 
    # @return [Boolean]
    def valid?
      SSHKey.valid_ssh_public_key?(@content)
    end

    # Get public key MD5 checksum
    # @return [String]
    def md5
      Digest::MD5.hexdigest(@content)
    end

    # Get public key SHA1 checksum
    # @return [String]
    def sha1
      Digest::SHA1.hexdigest(@content)
    end

    # Convert public key to system key with arbitrary command
    # @param [String] command arbitrary command
    # @return [String]
    def to_system_key(command)
      "command=\"#{command}\",#{COMMAND_OPTIONS.join(",")} #{@content}"
    end

    private

    def cleanup_content(str)
      str.to_s.strip.gsub(/(\r|\n)*/m, "")
    end
  end
end