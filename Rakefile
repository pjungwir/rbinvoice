# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rbinvoice"
  gem.homepage = "http://github.com/pjungwir/rbinvoice"
  gem.license = "MIT"
  gem.summary = 'Used to invoice my clients'
  gem.description = <<-EOT
      Reads hours from a Google Spreadsheet and generates a PDF invoice.
  EOT
  gem.email = "pj@illuminatedcomputing.com"
  gem.authors = ["Paul A. Jungwirth"]
  gem.executables << 'rbinvoice'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

=begin
RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end
=end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rbinvoice #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :run, [] => [] do |t, args|
  require 'rbinvoice'
  RbInvoice::write_invoice(*RbInvoice::Options::parse_command_line(%w{okvenue}))
end

task :readme => [] do |task|
  `markdown README.md >README.html`
end
