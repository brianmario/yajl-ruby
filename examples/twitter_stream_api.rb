require 'rubygems'
require 'yajl/http_stream'
require 'uri'
require 'socket'

unless (username = ARGV[0]) && (password = ARGV[1])
  puts "\nUsage: ruby examples/twitter_stream_api.rb username password\n\n"
  exit(0)
end

uri = URI.parse("http://#{username}:#{password}@stream.twitter.com/spritzer.json")

trap('INT') {
  puts "\n\nCTRL+C caught, bye!"
  exit(0)
}

Yajl::HttpStream.get(uri) do |hash|
  puts hash.inspect
end