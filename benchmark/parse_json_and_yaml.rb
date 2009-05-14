# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl'
require 'json'
require 'yaml'

# JSON section
filename = ARGV[0] || 'benchmark/subjects/contacts.json'
json = File.new(filename, 'r')

# warm up the filesystem
json.read
json.rewind

times = ARGV[1] ? ARGV[1].to_i : 1
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bm { |x|
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
      JSON.parse(json.read, :max_nesting => false)
    }
  }
}
json.close

# YAML section
filename = ARGV[0] || 'benchmark/subjects/contacts.yml'
yaml = File.new(filename, 'r')

# warm up the filesystem
yaml.read
yaml.rewind

times = ARGV[1] ? ARGV[1].to_i : 1
puts "Starting benchmark parsing #{File.size(filename)} bytes of YAML data #{times} times\n\n"
Benchmark.bm { |x|
  x.report {
    puts "YAML.load_stream"
    times.times {
      yaml.rewind
      YAML.load_stream(yaml)
    }
  }
}
yaml.close