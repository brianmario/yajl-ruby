# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../../lib')

require 'rubygems'
require 'yajl/http_stream'
require 'uri'

unless keywords = ARGV[0]
  puts "\nUsage: ruby examples/http/twitter_search_api.rb keyword\n\n"
  exit(0)
end
captured = 0
uri = URI.parse("http://search.twitter.com/search.json?q=#{keywords}")

puts Yajl::HttpStream.get(uri).inspect