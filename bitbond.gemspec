# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitbond/version'

Gem::Specification.new do |gem|
  gem.name          = "bitbond"
  gem.version       = Bitbond::VERSION
  gem.authors       = ["Michal"]
  gem.email         = ["api@bitbond.com"]
  gem.description   = "Client library for Bitbond API"
  gem.summary       = "Client library for Bitbond API"
  gem.homepage      = "https://www.bitbond.com/api"

  gem.files         = `git ls-files`.split($/)
  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|gem|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'oauth2'

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "timecop"
  gem.add_development_dependency "pry-byebug"
end
