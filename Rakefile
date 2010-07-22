require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'

desc "Default Task"
task :default => [:test]

Rake::TestTask.new :test do |test|
  test.verbose = false
  test.test_files = ['test/*_test.rb']
end

gem_spec = Gem::Specification.new do |spec|
  spec.name = 'resource'
  spec.version = '1.0.0'
  spec.summary = 'Spectra Logic Resource System'
  spec.author = 'Spectra Logic'
  spec.has_rdoc = false
  candidates = Dir.glob("{lib}/**/*")
  spec.files = candidates.delete_if {|c| c.match(/\.swp|\.svn|html|pkg/)}
  spec.add_dependency('ruby_protobuf')
end

gem = Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_tar = false
  pkg.need_zip = false
end
