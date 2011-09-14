require './lib/yajl/version'

# git should not be included in gemspec but rather that rewrite the gemspect
# use this hack to make it a little smarter
# only a issue if you are using bundler and path=> or :git=> params
gitpath = '/usr/local/bin/git' if File::exists?( "/usr/local/bin/git" )
gitpath = gitpath || '/usr/local/git/bin/git' if File::exists?("/usr/local/git/bin/git")
gitpath = gitpath || "git"


Gem::Specification.new do |s|
  s.name = %q{yajl-ruby}
  s.version = Yajl::VERSION
  s.authors = ["Brian Lopez", "Lloyd Hilaiel"]
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.email = %q{seniorlopez@gmail.com}
  s.extensions = ["ext/yajl/extconf.rb"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]

  s.files = `#{gitpath} ls-files`.split("\n")
  s.test_files = `#{gitpath} ls-files spec examples`.split("\n")

  s.homepage = %q{http://github.com/brianmario/yajl-ruby}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Ruby C bindings to the excellent Yajl JSON stream-based parser library.}


  # tests
  s.add_development_dependency 'rake-compiler', ">= 0.7.5"
  s.add_development_dependency 'rspec', ">= 2.0.0"
  # benchmarks
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'json'
end

