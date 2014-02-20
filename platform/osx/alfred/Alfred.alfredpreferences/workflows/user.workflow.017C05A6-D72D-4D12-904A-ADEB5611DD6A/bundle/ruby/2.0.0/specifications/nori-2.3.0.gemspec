# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "nori"
  s.version = "2.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Harrington", "John Nunemaker", "Wynn Netherland"]
  s.date = "2013-07-26"
  s.description = "XML to Hash translator"
  s.email = "me@rubiii.com"
  s.homepage = "https://github.com/savonrb/nori"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "nori"
  s.rubygems_version = "2.0.3"
  s.summary = "XML to Hash translator"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<nokogiri>, ["< 1.6", ">= 1.4.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.12"])
    else
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<nokogiri>, ["< 1.6", ">= 1.4.0"])
      s.add_dependency(%q<rspec>, ["~> 2.12"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<nokogiri>, ["< 1.6", ">= 1.4.0"])
    s.add_dependency(%q<rspec>, ["~> 2.12"])
  end
end
