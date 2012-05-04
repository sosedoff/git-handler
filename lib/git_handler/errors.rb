module GitHandler
  class Error              < StandardError ; end
  class SessionError       < Error ; end
  class ParseError         < Error ; end
  class ConfigurationError < Error ; end
end