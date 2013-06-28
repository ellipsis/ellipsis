# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "alfred-workflow"
  s.version = "1.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zhao Cai"]
  s.date = "2013-03-28"
  s.description = "alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow."
  s.email = ["caizhaoff@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt"]
  s.homepage = "https://github.com/zhaocai/alfred-workflow"
  s.licenses = ["GPL-3"]
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "alfred-workflow"
  s.rubygems_version = "2.0.3"
  s.summary = "alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<plist>, ["~> 3.1.0"])
      s.add_runtime_dependency(%q<logging>, ["~> 1.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<hoe>, ["~> 3.5"])
    else
      s.add_dependency(%q<plist>, ["~> 3.1.0"])
      s.add_dependency(%q<logging>, ["~> 1.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<hoe>, ["~> 3.5"])
    end
  else
    s.add_dependency(%q<plist>, ["~> 3.1.0"])
    s.add_dependency(%q<logging>, ["~> 1.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<hoe>, ["~> 3.5"])
  end
end
