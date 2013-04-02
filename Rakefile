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

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec


Bundler::GemHelper.install_tasks

task :run, [] => [] do |t, args|
  require 'rbinvoice'
  RbInvoice::write_invoice(*RbInvoice::Options::parse_command_line(%w{okvenue}))
end

task :readme => [] do |task|
  `markdown README.md >README.html`
end
