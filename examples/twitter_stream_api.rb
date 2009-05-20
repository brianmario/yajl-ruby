require 'rubygems'
require 'yajl/http_stream'
require 'uri'
require 'socket'

username = ARGV[0]
password = ARGV[1]

uri = URI.parse("http://#{username}:#{password}@stream.twitter.com/spritzer.json")

trap('INT') {
  puts "\n\nCTRL+C caught, bye!"
  exit(0)
}

Yajl::HttpStream.get(uri) do |hash|
  puts hash.inspect
end