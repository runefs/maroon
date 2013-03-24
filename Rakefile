require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :generate do |t|
  require_relative './lib/maroon' #use the one in lib. That should be the stable one
  Context::generate_file = true #generate files not just in memory classes
  `git ls-files ./base/`.split($/).grep(%r{(.)*.rb}).select {|f| require_relative("#{f}")}
end

task :build_lib_setup do |t|
  require_relative './generated/build' #use the one in lib. That should be the stable one
  Context::do_generate_file #generate files not just in memory classes
  `git ls-files ./base/`.split($/).grep(%r{(.)*.rb}).select {|f| require_relative("#{f}")}
end

task :default => [:generate,:test]

task :build_lib => [:build_lib_setup,:test]