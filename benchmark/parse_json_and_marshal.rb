# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl_ext'
require 'json'

# JSON section
filename = 'benchmark/subjects/ohai.json'
marshal_filename = 'benchmark/subjects/ohai.marshal_dump'
json = File.new(filename, 'r')
marshal_file = File.new(marshal_filename, 'r')

# warm up the filesystem
json.read
json.rewind
marshal_file.read
marshal_file.rewind

hash = {}

times = ARGV[0] ? ARGV[0].to_i : 1
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bm { |x|
  x.report {
    puts "Yajl::Parser#parse"
    times.times {
      json.rewind
      hash = Yajl::Parser.new.parse(json)
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
    puts "Marshal.load"
    times.times {
      marshal_file.rewind
      Marshal.load(marshal_file)
    }
  }
}
json.close
marshal_file.close