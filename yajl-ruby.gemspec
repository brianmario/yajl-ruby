require './lib/yajl/version'

Gem::Specification.new do |s|
  s.name = %q{yajl-ruby}
  s.version = Yajl::VERSION
  s.authors = ["Brian Lopez", "Lloyd Hilaiel"]
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.email = %q{seniorlopez@gmail.com}
  s.extensions = ["ext/yajl/extconf.rb"]
  s.files = `git ls-files`.split("\n")
  s.homepage = %q{http://github.com/brianmario/yajl-ruby}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Ruby C bindings to the excellent Yajl JSON stream-based parser library.}
  s.test_files = `git ls-files spec examples`.split("\n")
  s.required_ruby_version = ">= 1.8.6"

  # tests
  s.add_development_dependency 'rake-compiler', ">= 0.7.5"
  s.add_development_dependency 'rspec', ">= 2.0.0"
  # benchmarks
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'json'
end

