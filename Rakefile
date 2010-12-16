require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'

desc "Default Task"
task :default => [:test]

Rake::TestTask.new :test do |test|
  test.verbose = false
  test.test_files = ['test/*_test.rb']
end

Rake::TestTask.new "test:cim" do |test|
  test.verbose = false
  test.test_files = ['test/cim/*_test.rb']
end

Rake::TestTask.new "test:redis" do |test|
  test.verbose = false
  test.test_files = ['test/redis/*_test.rb']
end

gem_spec = Gem::Specification.new do |spec|
  spec.name = 'activeservice'
  spec.version = '1.0.0'
  spec.summary = 'Active Service'
  spec.author = 'Josh Carter'
  spec.email = 'public@joshcarter.com'
  spec.homepage = 'http://github.com/joshcarter/activeservice'
  spec.rubyforge_project = 'activeservice'
  spec.has_rdoc = false
  spec.license = 'BSD'
  candidates = Dir.glob("{lib}/**/*")
  spec.files = candidates.delete_if {|c| c.match(/\.swp|\.svn|html|pkg/)}
  spec.add_dependency('dnssd')
  spec.add_development_dependency('mocha')
  
  spec.description = <<-EOF
    ActiveService is a high-level framework for dynamic service 
    discovery using DNS-SD.
  EOF
end

gem = Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_tar = false
  pkg.need_zip = false
end
