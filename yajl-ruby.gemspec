# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{yajl-ruby}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Lopez"]
  s.date = %q{2009-04-24}
  s.email = %q{seniorlopez@gmail.com}
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "CHANGELOG.rdoc",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/brianmario/yajl-ruby}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["ext"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Ruby C bindings to the excellent Yajl JSON stream-based parser library.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
