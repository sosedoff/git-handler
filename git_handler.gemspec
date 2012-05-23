require File.expand_path('../lib/git_handler/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "git_handler"
  s.version     = GitHandler::VERSION
  s.summary     = "Server-side git request handler"
  s.description = "Set of tool to simplify custom git server setup"
  s.homepage    = "http://github.com/sosedoff/git_handler"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'rake',      '~> 0.8'
  s.add_development_dependency 'rspec',     '~> 2.6'
  s.add_development_dependency 'simplecov', '~> 0.4'

  s.add_runtime_dependency 'sshkey', '~> 1.3'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end