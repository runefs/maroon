# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'maroon/version'

Gem::Specification.new do |gem|
  gem.name = 'maroon'
  gem.version = Maroon::VERSION
  gem.authors = ['Rune Funch Søltoft']
  gem.email = %w(funchsoltoft@gmail.com)
  gem.description = %q{maroon makes DCI a DSL for Ruby it's mainly based on the work gone into Marvin,
the first language to support injectionless DCI.

The performance of code written using maroon is on par with code using regular method invocation.

For examples on how to use maroon look at the examples found at the home page}
  gem.summary = %q{maroon}
  gem.homepage = 'https://github.com/runefs/Moby'

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency 'sourcify', '~> 0.6.0.rc4'
  gem.add_runtime_dependency 'sorcerer', "~> 1.0.2"
end
