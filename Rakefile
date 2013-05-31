require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/alltests.rb']
  t.verbose = true
end

task :generate do |t|

  require_relative './lib/Context'
  require_relative './lib/maroon/kernel'
  require_relative './lib/build' #use the one in lib. That should be the stable one
  Context::generate_files_in=:generated #generate files not just in memory classes
  `git ls-files ./base/`.split($/).grep(%r{(.)*.rb}).select {|f| require_relative("#{f}")}
end

#execute as with command line to make memory spaces independent
task :build_lib_setup do |t|
  generate_out = `rake generate`
  raise generate_out if generate_out and generate_out != ''
  test_res = {}
  test_out = `rake test`
  test_out.split(/[\n,]/)[-5..-1].each do |e|
    pair = e.strip.split(/\s/)
    test_res[pair[-1].to_sym] = pair[0].to_i
  end
  raise test_out if (test_res[:failures] + test_res[:errors] != 0)
  generate_out = `rake build_generate`
  raise generate_out if generate_out and generate_out != ''
end

task :build_generate do |t|
  require_relative './generated/build' #use the one previously generated
  Context::generate_files_in('lib') #generate files
  `git ls-files ./base/`.split($/).grep(%r{(.)*.rb}).select {|f| require_relative("#{f}")}
end

task :default => [:generate,:test]

task :build_lib => [:build_lib_setup,:test]