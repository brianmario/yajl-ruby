# encoding: UTF-8

require 'rubygems'
require 'yajl'

# Usage: cat benchmark/subjects/item.json | ruby examples/from_stdin.rb

hash = Yajl::Parser.parse(STDIN)
puts hash.inspect