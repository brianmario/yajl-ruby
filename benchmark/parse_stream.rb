# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl_ext'
require 'json'
# require 'activesupport'

filename = 'benchmark/subjects/twitter_stream.json'
json = File.new(filename, 'r')

# warm up the filesystem
json.read
json.rewind

times = ARGV[0] ? ARGV[0].to_i : 1
puts "Starting benchmark parsing JSON stream (#{File.size(filename)} bytes of JSON data with 430 JSON separate strings) #{times} times\n\n"
Benchmark.bm { |x|
  parser = Yajl::Parser.new
  parser.on_parse_complete = lambda { |obj|
    # no-op
  }
  x.report {
    puts "Yajl::Parser#parse"
    times.times {
      json.rewind
      parser.parse(json)
    }
  }
  x.report {
    puts "JSON.parse"
    times.times {
      json.rewind
      while chunk = json.gets
        JSON.parse(chunk, :max_nesting => false)
      end
    }
  }
  # x.report {
  #   puts "ActiveSupport::JSON.decode"
  #   times.times {
  #     json.rewind
  #     while chunk = json.gets
  #       ActiveSupport::JSON.decode(chunk)
  #     end
  #   }
  # }
}
json.close