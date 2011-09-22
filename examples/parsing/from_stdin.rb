$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)

require 'yajl'

# Usage: cat benchmark/subjects/item.json | ruby examples/from_stdin.rb

hash = Yajl::Parser.parse(STDIN)
puts hash.inspect