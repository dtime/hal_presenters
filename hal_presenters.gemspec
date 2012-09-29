# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hal_presenters/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Haslem"]
  gem.email         = ["therabidbanana@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hal_presenters"
  gem.require_paths = ["lib"]
  gem.add_dependency('addressable', '>= 2.3.2')
  gem.version       = HalPresenters::VERSION
end
