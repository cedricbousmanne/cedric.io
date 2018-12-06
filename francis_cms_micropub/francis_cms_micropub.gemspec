$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "francis_cms_micropub/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "francis_cms_micropub"
  s.version     = FrancisCmsMicropub::VERSION
  s.authors     = ["cedric"]
  s.email       = ["cedric@studio-sept.be"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of FrancisCmsMicropub."
  s.description = "TODO: Description of FrancisCmsMicropub."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.10"

  s.add_development_dependency "sqlite3"
end
