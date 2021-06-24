require './lib/yajl/version'

Gem::Specification.new do |s|
  s.name = %q{yajl-ruby}
  s.version = Yajl::VERSION
  s.license = "MIT"
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
  s.required_ruby_version = ">= 2.6.0"

  # tests
  s.add_development_dependency "rake-compiler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "minitest"
  # benchmarks
  s.add_development_dependency "activesupport"
  s.add_development_dependency "json"
  s.add_development_dependency "benchmark-memory"
end
