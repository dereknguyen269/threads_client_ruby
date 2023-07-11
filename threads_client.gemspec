require_relative 'lib/threads_client/version'
Gem::Specification.new do |s|
  s.name        = "threads_client"
  s.version     = ThreadsClient::VERSION
  s.summary     = "Threads client for ruby"
  s.description = "Threads client for ruby"
  s.authors     = ["Derek Nguyen"]
  s.email       = "derek.nguyen.269@gmail.com"
  s.homepage    = "https://rubygems.org/gems/threads_client"
  s.license     = "MIT"

  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency 'httparty'
end
