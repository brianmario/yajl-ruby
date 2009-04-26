# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require '../yajl.bundle'
require '../lib/yajl/http_stream'
require 'json'
require 'activesupport'
require 'uri'
require 'net/http'

uri = URI.parse('http://127.0.0.1:3000/contacts/off_disk')

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
      resp = Net::HTTP.get_response(uri)
      JSON.parse(resp.body, :max_nesting => false)
    }
  }
}