# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl_ext'
require 'json'
require 'yaml'

# JSON section
filename = 'benchmark/subjects/ohai.json'
json = File.new(filename, 'r')

# warm up the filesystem
json.read
json.rewind

times = ARGV[0] ? ARGV[0].to_i : 1
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bm { |x|
  parser = Yajl::Parser.new
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
      JSON.parse(json.read, :max_nesting => false)
    }
  }
}
json.close

# YAML section
filename = 'benchmark/subjects/contacts.yml'
yaml = File.new(filename, 'r')

# warm up the filesystem
yaml.read
yaml.rewind

times = ARGV[0] ? ARGV[0].to_i : 1
puts "Starting benchmark parsing #{File.size(filename)} bytes of YAML data #{times} times\n\n"
Benchmark.bm { |x|
  x.report {
    puts "YAML.load_stream"
    times.times {
      yaml.rewind
      YAML.load(yaml)
    }
  }
}
yaml.close