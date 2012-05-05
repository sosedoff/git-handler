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

    def valid?
      SSHKey.valid_ssh_public_key?(@content)
    end

    def md5
      Digest::MD5.hexdigest(@content)
    end

    def sha1
      Digest::SHA1.hexdigest(@content)
    end

    def to_system_key(command)
      "command=\"#{command}\",#{COMMAND_OPTIONS.join(",")} #{@content}"
    end

    private

    def cleanup_content(str)
      str.to_s.strip.gsub(/(\r|\n)*/m, "")
    end
  end
end