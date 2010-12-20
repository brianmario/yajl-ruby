begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "yajl-ruby"
    gem.summary = "Ruby C bindings to the excellent Yajl JSON stream-based parser library."
    gem.email = "seniorlopez@gmail.com"
    gem.homepage = "http://github.com/brianmario/yajl-ruby"
    gem.authors = ["Brian Lopez", "Lloyd Hilaiel"]
    gem.require_paths = ["lib", "ext"]
    gem.extra_rdoc_files = `git ls-files *.rdoc`.split("\n")
    gem.files = `git ls-files`.split("\n")
    gem.extensions = ["ext/yajl/extconf.rb"]
    gem.files.include %w(lib/jeweler/templates/.document lib/jeweler/templates/.gitignore)
  end
rescue LoadError
  puts "jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler -s http://gems.github.com"
end