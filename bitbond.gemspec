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
  gem.licenses      = ['MIT']
  gem.homepage      = "https://github.com/bitbond/bitbond-ruby"

  gem.files         = `git ls-files`.split($/)
  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|gem|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'oauth2', '~> 1.0'


  gem.add_development_dependency "rake", '~> 10.0'
  gem.add_development_dependency "rspec", '~> 3.4'
  gem.add_development_dependency "webmock", '~> 1.0'
  gem.add_development_dependency "timecop", '~> 0.8'
end
