# encoding: UTF-8

require 'rubygems'
require 'yajl'
require 'stringio'

unless string = ARGV[0]
  puts "\nUsage: ruby examples/from_string.rb '{\"foo\": 1145}'\n\n"
  exit(0)
end

json = StringIO.new(string)

hash = Yajl::Parser.parse(json)
puts hash.inspect