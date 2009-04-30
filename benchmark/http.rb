# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl'
require 'yajl/http_stream'
require 'json'
require 'activesupport'
require 'uri'
require 'net/http'

uri = URI.parse('http://search.twitter.com/search.json?q=github')

times = ARGV[0] ? ARGV[0].to_i : 1
puts "Starting benchmark parsing #{uri.to_s} #{times} times\n\n"
Benchmark.bm { |x|
  x.report {
    puts "Yajl::HttpStream.get"
    times.times {
      Yajl::HttpStream.get(uri)
    }
  }
  x.report {
    puts "JSON.parser"
    times.times {
      JSON.parse(Net::HTTP.get_response(uri).body, :max_nesting => false)
    }
  }
}