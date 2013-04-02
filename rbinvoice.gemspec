$:.push File.dirname(__FILE__) + "/lib"
require 'rbinvoice/version'

Gem::Specification.new do |s|
  s.name = "rbinvoice"
  s.version = RbInvoice::VERSION

  s.summary = "Used to invoice my clients"
  s.description = "      Reads hours from a Google Spreadsheet and generates a PDF invoice.\n"
  s.homepage = "http://github.com/pjungwir/rbinvoice"
  s.date = "2013-03-15"
  s.authors = ["Paul A. Jungwirth"]
  s.email = "pj@illuminatedcomputing.com"

  s.licenses = ["MIT"]

  s.require_paths = ["lib"]
  s.executables = ["rbinvoice", "rbinvoice"]
  s.rubygems_version = "1.8.24"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,fixtures}/*`.split("\n")

  s.add_runtime_dependency 'trollop', '>= 0'
  s.add_runtime_dependency 'roo', '>= 0'
  s.add_runtime_dependency 'prawn', '>= 0'
  s.add_runtime_dependency 'liquid', '>= 0'

  s.add_development_dependency 'rspec', '~> 2.4.0'
  s.add_development_dependency 'bundler', '>= 0'

end

