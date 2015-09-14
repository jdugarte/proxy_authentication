$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "proxy_authentication/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "proxy_authentication"
  s.version     = ProxyAuthentication::VERSION
  s.authors     = ["Jesús Dugarte"]
  s.email       = ["jdugarte@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ProxyAuthentication."
  s.description = "TODO: Description of ProxyAuthentication."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4"
  s.add_dependency "warden", "~> 1.2.3"

  s.add_development_dependency "sqlite3"
end
