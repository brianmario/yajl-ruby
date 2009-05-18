# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl_ext'
require 'json'

# JSON section
filename = 'benchmark/subjects/contacts.json'
json = File.new(filename, 'r')

# warm up the filesystem
json.read
json.rewind

hash = {}

times = ARGV[0] ? ARGV[0].to_i : 1
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bm { |x|
  x.report {
    puts "Yajl::Stream.parse"
    times.times {
      json.rewind
      hash = Yajl::Stream.parse(json)
    }
  }
  x.report {
    puts "JSON.parser"
    times.times {
      json.rewind
      JSON.parse(json.read, :max_nesting => false)
    }
  }
  data = Marshal.dump(hash)
  x.report {
    puts "Marshal.load"
    times.times {
      Marshal.load(data)
    }
  }
}
json.close