require "./lib/net/tns/gem_version"

Gem::Specification.new do |s|
  s.name = "net-tns"
  s.version = Net::TNS::VERSION
  s.summary = "Ruby implementation of the Oracle TNS protocol"
  s.description = "A pure Ruby (partial) implementation of the Oracle TNS protocol"

  s.authors = ["Chris Woodbury", "Eric Monti"]
  s.email = "woodbusy@gmail.com"
  s.homepage = "https://github.com/SpiderLabs/net-tns"
  s.license = "Apache-2.0"

  s.files = ["LICENSE"] + Dir.glob("{bin,lib}/**/*")
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.0.0"

  s.add_dependency("bindata", "~> 2.0")

  s.add_development_dependency("rspec", "~> 3.0")
  s.add_development_dependency("rspec-its", "~> 1.0")
  s.add_development_dependency("coveralls")
end
