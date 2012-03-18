# -*- encoding: utf-8 -*-
require File.expand_path('../lib/flowerbox/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["John Bintz"]
  gem.email         = ["john@coswellproductions.com"]
  gem.description   = %q{No-nonsense JavaScript testing solution.}
  gem.summary       = %q{No-nonsense JavaScript testing solution.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "flowerbox"
  gem.require_paths = ["lib"]
  gem.version       = Flowerbox::VERSION

  gem.add_development_dependency 'cucumber'
  gem.add_development_dependency 'rspec'

  gem.add_dependency 'jasmine-core'
  gem.add_dependency 'thor'
  gem.add_dependency 'selenium-webdriver'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'rainbow'
  gem.add_dependency 'sprockets-vendor_gems'
end
