# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{yajl-ruby}
  s.version = "0.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Lopez"]
  s.date = %q{2009-05-05}
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
    "lib/yajl/bzip2/stream_reader.rb",
    "lib/yajl/gzip/stream_reader.rb",
    "lib/yajl/http_stream.rb",
    "spec/active_support_spec.rb",
    "spec/fixtures/fail.15.json",
    "spec/fixtures/fail.16.json",
    "spec/fixtures/fail.17.json",
    "spec/fixtures/fail.26.json",
    "spec/fixtures/fail11.json",
    "spec/fixtures/fail12.json",
    "spec/fixtures/fail13.json",
    "spec/fixtures/fail14.json",
    "spec/fixtures/fail19.json",
    "spec/fixtures/fail20.json",
    "spec/fixtures/fail21.json",
    "spec/fixtures/fail22.json",
    "spec/fixtures/fail23.json",
    "spec/fixtures/fail24.json",
    "spec/fixtures/fail25.json",
    "spec/fixtures/fail27.json",
    "spec/fixtures/fail28.json",
    "spec/fixtures/fail3.json",
    "spec/fixtures/fail4.json",
    "spec/fixtures/fail5.json",
    "spec/fixtures/fail6.json",
    "spec/fixtures/fail9.json",
    "spec/fixtures/pass.array.json",
    "spec/fixtures/pass.codepoints_from_unicode_org.json",
    "spec/fixtures/pass.contacts.json",
    "spec/fixtures/pass.db100.xml.json",
    "spec/fixtures/pass.db1000.xml.json",
    "spec/fixtures/pass.dc_simple_with_comments.json",
    "spec/fixtures/pass.deep_arrays.json",
    "spec/fixtures/pass.difficult_json_c_test_case.json",
    "spec/fixtures/pass.difficult_json_c_test_case_with_comments.json",
    "spec/fixtures/pass.doubles.json",
    "spec/fixtures/pass.empty_array.json",
    "spec/fixtures/pass.empty_string.json",
    "spec/fixtures/pass.escaped_bulgarian.json",
    "spec/fixtures/pass.escaped_foobar.json",
    "spec/fixtures/pass.item.json",
    "spec/fixtures/pass.json-org-sample1.json",
    "spec/fixtures/pass.json-org-sample2.json",
    "spec/fixtures/pass.json-org-sample3.json",
    "spec/fixtures/pass.json-org-sample4-nows.json",
    "spec/fixtures/pass.json-org-sample4.json",
    "spec/fixtures/pass.json-org-sample5.json",
    "spec/fixtures/pass.map-spain.xml.json",
    "spec/fixtures/pass.ns-invoice100.xml.json",
    "spec/fixtures/pass.ns-soap.xml.json",
    "spec/fixtures/pass.numbers-fp-4k.json",
    "spec/fixtures/pass.numbers-fp-64k.json",
    "spec/fixtures/pass.numbers-int-4k.json",
    "spec/fixtures/pass.numbers-int-64k.json",
    "spec/fixtures/pass.twitter-search.json",
    "spec/fixtures/pass.twitter-search2.json",
    "spec/fixtures/pass.unicode.json",
    "spec/fixtures/pass.yelp.json",
    "spec/fixtures/pass1.json",
    "spec/fixtures/pass2.json",
    "spec/fixtures/pass3.json",
    "spec/fixtures_spec.rb",
    "spec/one_off_spec.rb",
    "spec/spec_helper.rb",
    "yajl-ruby.gemspec"
  ]
  s.homepage = %q{http://github.com/brianmario/yajl-ruby}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Ruby C bindings to the excellent Yajl JSON stream-based parser library.}
  s.test_files = [
    "spec/active_support_spec.rb",
    "spec/fixtures_spec.rb",
    "spec/one_off_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
