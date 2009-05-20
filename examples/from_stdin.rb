require 'rubygems'
require 'yajl'

# Usage: cat benchmark/subjects/item.json | ruby examples/from_stdin.rb

hash = Yajl::Stream.parse(STDIN)
puts hash.inspect