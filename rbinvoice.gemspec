# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rbinvoice"
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul A. Jungwirth"]
  s.date = "2012-08-23"
  s.description = "      Reads hours from a Google Spreadsheet and generates a PDF invoice.\n"
  s.email = "pj@illuminatedcomputing.com"
  s.executables = ["rbinvoice", "rbinvoice"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md",
    "TODO"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "NOTES",
    "README.md",
    "Rakefile",
    "TODO",
    "VERSION",
    "bin/rbinvoice",
    "lib/rbinvoice.rb",
    "lib/rbinvoice/options.rb",
    "lib/rbinvoice/util.rb",
    "rbinvoice.gemspec",
    "spec/options_spec.rb",
    "templates/invoice.tex.liquid"
  ]
  s.homepage = "http://github.com/pjungwir/rbinvoice"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Used to invoice my clients"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<trollop>, [">= 0"])
      s.add_runtime_dependency(%q<roo>, [">= 0"])
      s.add_runtime_dependency(%q<prawn>, [">= 0"])
      s.add_runtime_dependency(%q<liquid>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<trollop>, [">= 0"])
      s.add_dependency(%q<roo>, [">= 0"])
      s.add_dependency(%q<prawn>, [">= 0"])
      s.add_dependency(%q<liquid>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<trollop>, [">= 0"])
    s.add_dependency(%q<roo>, [">= 0"])
    s.add_dependency(%q<prawn>, [">= 0"])
    s.add_dependency(%q<liquid>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

