$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "beacon_attached/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "beacon_attached"
  s.version     = BeaconAttached::VERSION
  s.authors     = ["Yeah"]
  s.email       = ["yeah@yu.fm"]
  s.homepage    = ""
  s.summary     = "Beacon attachment service. Like paperclip, combined qiniu cloud and with javascript uploading"
  s.description = "Beacon attachment service. Like paperclip, combined qiniu cloud and with javascript uploading"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency "sqlite3"
end
