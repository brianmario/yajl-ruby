# encoding: UTF-8

require 'rubygems'
require 'yajl'

unless file = ARGV[0]
  puts "\nUsage: ruby examples/from_file.rb benchmark/subjects/item.json\n\n"
  exit(0)
end

json = File.new(file, 'r')

hash = Yajl::Parser.parse(json)
puts hash.inspect