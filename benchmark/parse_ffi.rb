# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'benchmark'
require 'yajl/ffi'
require 'json'
require 'activesupport'

filename = ARGV[0] || 'benchmark/subjects/ohai.json'
json = File.new(filename, 'r')

# warm up the filesystem
json.read
json.rewind

times = ARGV[1] ? ARGV[1].to_i : 1
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bm { |x|
  io_parser = Yajl::FFI::Parser.new
  x.report {
    puts "Yajl::FFI::Parser#parse (from an IO)"
    times.times {
      json.rewind
      io_parser.parse(json)
    }
  }
  string_parser = Yajl::FFI::Parser.new
  x.report {
    puts "Yajl::FFI::Parser#parse (from a String)"
    times.times {
      json.rewind
      string_parser.parse(json.read)
    }
  }
  x.report {
    puts "JSON.parse"
    times.times {
      json.rewind
      JSON.parse(json.read, :max_nesting => false)
    }
  }
  x.report {
    puts "ActiveSupport::JSON.decode"
    times.times {
      json.rewind
      ActiveSupport::JSON.decode(json.read)
    }
  }
}
json.close