# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "moneta"
  s.version = "0.7.20"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Mendler", "Yehuda Katz", "Hannes Georg"]
  s.date = "2013-09-30"
  s.description = "A unified interface to key/value stores"
  s.email = ["mail@daniel-mendler.de", "wycats@gmail.com", "hannes.georg@googlemail.com"]
  s.extra_rdoc_files = ["README.md", "SPEC.md", "LICENSE"]
  s.files = ["README.md", "SPEC.md", "LICENSE"]
  s.homepage = "http://github.com/minad/moneta"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "A unified interface to key/value stores, including Redis, Memcached, TokyoCabinet, ActiveRecord and many more"
end
