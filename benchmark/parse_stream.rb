# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl_ext'
require 'json'
require 'activesupport'

puts "\nWARNING: I'm still working on getting the streaming parsing to work correctly"
puts "The results of this benchmark aren't currently accurate.\n\n"

filename = 'benchmark/subjects/twitter_stream.json'
json = File.new(filename, 'r')

# warm up the filesystem
json.read
json.rewind

times = ARGV[0] ? ARGV[0].to_i : 1
puts "Starting benchmark parsing JSON stream (#{File.size(filename)} bytes of JSON data) #{times} times\n\n"
Benchmark.bm { |x|
  Yajl::Chunked.on_parse_complete = lambda { |obj|
    # no-op
  }
  x.report {
    puts "Yajl::Stream.parse"
    times.times {
      json.rewind
      Yajl::Stream.parse(json)
    }
  }
  x.report {
    puts "JSON.parser"
    times.times {
      json.rewind
      while chunk = json.gets
        JSON.parse(chunk, :max_nesting => false)
      end
    }
  }
  x.report {
    puts "ActiveSupport::JSON.decode"
    times.times {
      json.rewind
      while chunk = json.gets
        ActiveSupport::JSON.decode(chunk)
      end
    }
  }
}
json.close