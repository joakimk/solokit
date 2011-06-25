# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "solokit/version"

Gem::Specification.new do |s|
  s.name        = "solokit"
  s.version     = Solokit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joakim Kolsjö"]
  s.email       = ["joakim.kolsjo@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{}
  s.description = %q{}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport", ">= 3.0.0"
  s.add_development_dependency "bundler"
end
