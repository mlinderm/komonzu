# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "komonzu/version"

Gem::Specification.new do |s|
  s.name        = "komonzu"
  s.version     = Komonzu::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Linderman"]
  s.email       = ["michael.d.linderman@gmail.com"]
  s.homepage    = "http://komonzu.com"
  s.summary     = %q{Client library and CLI to manage Komonzu.}
  s.description = %q{Client library and command line tool to manage projects and applications on Komonzu.}
 
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
