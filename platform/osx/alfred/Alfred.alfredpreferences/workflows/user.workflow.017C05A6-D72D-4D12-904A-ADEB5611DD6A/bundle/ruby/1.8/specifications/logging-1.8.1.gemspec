# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "logging"
  s.version = "1.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = "2013-01-02"
  s.description = "Logging is a flexible logging library for use in Ruby programs based on the\ndesign of Java's log4j library. It features a hierarchical logging system,\ncustom level names, multiple output destinations per log event, custom\nformatting, and more."
  s.email = "tim.pease@gmail.com"
  s.extra_rdoc_files = ["History.txt", "README.rdoc"]
  s.files = ["History.txt", "README.rdoc"]
  s.homepage = "http://rubygems.org/gems/logging"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "logging"
  s.rubygems_version = "2.0.3"
  s.summary = "A flexible and extendable logging library for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<little-plugger>, [">= 1.1.3"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.3.6"])
      s.add_development_dependency(%q<flexmock>, ["~> 1.0"])
      s.add_development_dependency(%q<bones-git>, [">= 1.3.0"])
      s.add_development_dependency(%q<bones>, [">= 3.8.0"])
    else
      s.add_dependency(%q<little-plugger>, [">= 1.1.3"])
      s.add_dependency(%q<multi_json>, [">= 1.3.6"])
      s.add_dependency(%q<flexmock>, ["~> 1.0"])
      s.add_dependency(%q<bones-git>, [">= 1.3.0"])
      s.add_dependency(%q<bones>, [">= 3.8.0"])
    end
  else
    s.add_dependency(%q<little-plugger>, [">= 1.1.3"])
    s.add_dependency(%q<multi_json>, [">= 1.3.6"])
    s.add_dependency(%q<flexmock>, ["~> 1.0"])
    s.add_dependency(%q<bones-git>, [">= 1.3.0"])
    s.add_dependency(%q<bones>, [">= 3.8.0"])
  end
end
