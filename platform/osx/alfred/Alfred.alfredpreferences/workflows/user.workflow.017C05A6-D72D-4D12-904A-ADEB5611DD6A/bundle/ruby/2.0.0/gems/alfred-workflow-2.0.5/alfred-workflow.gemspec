# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "alfred-workflow"
  s.version = "2.0.1.20131023093234"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zhao Cai"]
  s.date = "2013-10-23"
  s.description = "alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow."
  s.email = ["caizhaoff@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.md", "History.txt"]
  s.files = [".gemtest", ".rspec", ".ruby-version", "Gemfile", "Gemfile.lock", "Guardfile", "History.txt", "Manifest.txt", "README.md", "Rakefile", "alfred-workflow.gemspec", "lib/alfred.rb", "lib/alfred/feedback.rb", "lib/alfred/feedback/file_item.rb", "lib/alfred/feedback/item.rb", "lib/alfred/feedback/webloc_item.rb", "lib/alfred/handler.rb", "lib/alfred/handler/autocomplete.rb", "lib/alfred/handler/callback.rb", "lib/alfred/handler/cofig.rb", "lib/alfred/handler/help.rb", "lib/alfred/osx.rb", "lib/alfred/setting.rb", "lib/alfred/ui.rb", "lib/alfred/util.rb", "lib/alfred/version.rb", "spec/alfred/feedback/item_spec.rb", "spec/alfred/feedback_spec.rb", "spec/alfred/setting_spec.rb", "spec/alfred/ui_spec.rb", "spec/alfred_spec.rb", "spec/spec_helper.rb", "test/workflow/info.plist", "test/workflow/setting.yaml"]
  s.homepage = "http://zhaocai.github.com/alfred2-ruby-template/"
  s.licenses = ["GPL-3"]
  s.rdoc_options = ["--title", "TestAlfred::TestWorkflow Documentation", "--quiet"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "alfred-workflow"
  s.rubygems_version = "2.0.3"
  s.summary = "alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<plist>, [">= 3.1.0"])
      s.add_runtime_dependency(%q<moneta>, [">= 0.7.19"])
      s.add_runtime_dependency(%q<gyoku>, [">= 1.1.0"])
      s.add_runtime_dependency(%q<nori>, [">= 2.3.0"])
      s.add_runtime_dependency(%q<fuzzy_match>, [">= 2.0.4"])
      s.add_runtime_dependency(%q<terminal-notifier>, [">= 1.5.0"])
      s.add_development_dependency(%q<hoe-yard>, [">= 0.1.2"])
      s.add_development_dependency(%q<awesome_print>, [">= 1.2.0"])
      s.add_development_dependency(%q<rspec>, [">= 2.13"])
      s.add_development_dependency(%q<facets>, [">= 2.9.0"])
      s.add_development_dependency(%q<rake>, [">= 10.0.0"])
      s.add_development_dependency(%q<hoe>, [">= 0"])
      s.add_development_dependency(%q<hoe-gemspec>, [">= 0"])
      s.add_development_dependency(%q<hoe-git>, [">= 0"])
      s.add_development_dependency(%q<hoe-version>, [">= 0"])
      s.add_development_dependency(%q<hoe-travis>, [">= 0"])
      s.add_development_dependency(%q<guard>, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
      s.add_development_dependency(%q<guard-bundler>, [">= 0"])
      s.add_development_dependency(%q<terminal-notifier-guard>, [">= 0"])
      s.add_development_dependency(%q<growl>, [">= 0"])
    else
      s.add_dependency(%q<plist>, [">= 3.1.0"])
      s.add_dependency(%q<moneta>, [">= 0.7.19"])
      s.add_dependency(%q<gyoku>, [">= 1.1.0"])
      s.add_dependency(%q<nori>, [">= 2.3.0"])
      s.add_dependency(%q<fuzzy_match>, [">= 2.0.4"])
      s.add_dependency(%q<terminal-notifier>, [">= 1.5.0"])
      s.add_dependency(%q<hoe-yard>, [">= 0.1.2"])
      s.add_dependency(%q<awesome_print>, [">= 1.2.0"])
      s.add_dependency(%q<rspec>, [">= 2.13"])
      s.add_dependency(%q<facets>, [">= 2.9.0"])
      s.add_dependency(%q<rake>, [">= 10.0.0"])
      s.add_dependency(%q<hoe>, [">= 0"])
      s.add_dependency(%q<hoe-gemspec>, [">= 0"])
      s.add_dependency(%q<hoe-git>, [">= 0"])
      s.add_dependency(%q<hoe-version>, [">= 0"])
      s.add_dependency(%q<hoe-travis>, [">= 0"])
      s.add_dependency(%q<guard>, [">= 0"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
      s.add_dependency(%q<guard-bundler>, [">= 0"])
      s.add_dependency(%q<terminal-notifier-guard>, [">= 0"])
      s.add_dependency(%q<growl>, [">= 0"])
    end
  else
    s.add_dependency(%q<plist>, [">= 3.1.0"])
    s.add_dependency(%q<moneta>, [">= 0.7.19"])
    s.add_dependency(%q<gyoku>, [">= 1.1.0"])
    s.add_dependency(%q<nori>, [">= 2.3.0"])
    s.add_dependency(%q<fuzzy_match>, [">= 2.0.4"])
    s.add_dependency(%q<terminal-notifier>, [">= 1.5.0"])
    s.add_dependency(%q<hoe-yard>, [">= 0.1.2"])
    s.add_dependency(%q<awesome_print>, [">= 1.2.0"])
    s.add_dependency(%q<rspec>, [">= 2.13"])
    s.add_dependency(%q<facets>, [">= 2.9.0"])
    s.add_dependency(%q<rake>, [">= 10.0.0"])
    s.add_dependency(%q<hoe>, [">= 0"])
    s.add_dependency(%q<hoe-gemspec>, [">= 0"])
    s.add_dependency(%q<hoe-git>, [">= 0"])
    s.add_dependency(%q<hoe-version>, [">= 0"])
    s.add_dependency(%q<hoe-travis>, [">= 0"])
    s.add_dependency(%q<guard>, [">= 0"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
    s.add_dependency(%q<guard-bundler>, [">= 0"])
    s.add_dependency(%q<terminal-notifier-guard>, [">= 0"])
    s.add_dependency(%q<growl>, [">= 0"])
  end
end
