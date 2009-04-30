# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{yajl-ruby}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Lopez"]
  s.date = %q{2009-04-30}
  s.email = %q{seniorlopez@gmail.com}
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = [
    "CHANGELOG.rdoc",
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
    "CHANGELOG.rdoc",
    "MIT-LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "benchmark/http.rb",
    "benchmark/stream.rb",
    "benchmark/subjects/contacts.json",
    "benchmark/subjects/item.json",
    "benchmark/subjects/ohai.json",
    "benchmark/subjects/twitter_search.json",
    "benchmark/subjects/unicode.json",
    "benchmark/subjects/yelp.json",
    "ext/extconf.rb",
    "ext/yajl.c",
    "ext/yajl.h",
    "lib/yajl.rb",
    "lib/yajl/http_stream.rb",
    "specs/active_support_spec.rb",
    "specs/fixtures/fail.15.json",
    "specs/fixtures/fail.16.json",
    "specs/fixtures/fail.17.json",
    "specs/fixtures/fail.26.json",
    "specs/fixtures/fail11.json",
    "specs/fixtures/fail12.json",
    "specs/fixtures/fail13.json",
    "specs/fixtures/fail14.json",
    "specs/fixtures/fail19.json",
    "specs/fixtures/fail20.json",
    "specs/fixtures/fail21.json",
    "specs/fixtures/fail22.json",
    "specs/fixtures/fail23.json",
    "specs/fixtures/fail24.json",
    "specs/fixtures/fail25.json",
    "specs/fixtures/fail27.json",
    "specs/fixtures/fail28.json",
    "specs/fixtures/fail3.json",
    "specs/fixtures/fail4.json",
    "specs/fixtures/fail5.json",
    "specs/fixtures/fail6.json",
    "specs/fixtures/fail9.json",
    "specs/fixtures/pass.array.json",
    "specs/fixtures/pass.codepoints_from_unicode_org.json",
    "specs/fixtures/pass.contacts.json",
    "specs/fixtures/pass.db100.xml.json",
    "specs/fixtures/pass.db1000.xml.json",
    "specs/fixtures/pass.dc_simple_with_comments.json",
    "specs/fixtures/pass.deep_arrays.json",
    "specs/fixtures/pass.difficult_json_c_test_case.json",
    "specs/fixtures/pass.difficult_json_c_test_case_with_comments.json",
    "specs/fixtures/pass.doubles.json",
    "specs/fixtures/pass.empty_array.json",
    "specs/fixtures/pass.empty_string.json",
    "specs/fixtures/pass.escaped_bulgarian.json",
    "specs/fixtures/pass.escaped_foobar.json",
    "specs/fixtures/pass.item.json",
    "specs/fixtures/pass.json-org-sample1.json",
    "specs/fixtures/pass.json-org-sample2.json",
    "specs/fixtures/pass.json-org-sample3.json",
    "specs/fixtures/pass.json-org-sample4-nows.json",
    "specs/fixtures/pass.json-org-sample4.json",
    "specs/fixtures/pass.json-org-sample5.json",
    "specs/fixtures/pass.map-spain.xml.json",
    "specs/fixtures/pass.ns-invoice100.xml.json",
    "specs/fixtures/pass.ns-soap.xml.json",
    "specs/fixtures/pass.numbers-fp-4k.json",
    "specs/fixtures/pass.numbers-fp-64k.json",
    "specs/fixtures/pass.numbers-int-4k.json",
    "specs/fixtures/pass.numbers-int-64k.json",
    "specs/fixtures/pass.twitter-search.json",
    "specs/fixtures/pass.twitter-search2.json",
    "specs/fixtures/pass.unicode.json",
    "specs/fixtures/pass.yelp.json",
    "specs/fixtures/pass1.json",
    "specs/fixtures/pass2.json",
    "specs/fixtures/pass3.json",
    "specs/fixtures_spec.rb",
    "specs/one_off_spec.rb",
    "specs/spec_helper.rb",
    "yajl-ruby.gemspec"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/brianmario/yajl-ruby}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["ext", "lib"]
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
