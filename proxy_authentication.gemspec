$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "proxy_authentication/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "proxy_authentication"
  s.version     = ProxyAuthentication::VERSION
  s.author      = "Jesús Dugarte"
  s.email       = "jdugarte@gmail.com"
  s.homepage    = "http://github.com/jdugarte/proxy_authentication/"
  s.summary     = "Rails user authentication, through a url token, originated in another rails app's authenticated user"
  s.description = <<-EOF
    ProxyAuthentication allows two Rails applications to share an authenticated user, through a url token.
    App A can (through its own authentication system, e.g. Devise) authenticate a user, and then generate a link to App B
    with the encoded user info (in the url token). App B can then validate the request and decode the user info.
  EOF
  s.license     = "MIT"

  s.files = Dir[ "{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc" ]
  s.test_files = Dir[ "test/**/*" ]

  s.add_dependency "rails", [ '>= 2.3.17', '< 5.0' ]
  s.add_dependency "warden", "~> 1.2.3"

  s.add_development_dependency "sqlite3"
end
