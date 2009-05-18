# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl_ext'
require 'activesupport'
require 'json'
require 'yaml'

# JSON Section
filename = 'benchmark/subjects/contacts.json'
json = File.new(filename, 'r')
hash = Yajl::Stream.parse(json)
json.close

times = ARGV[0] ? ARGV[0].to_i : 1
puts "Starting benchmark encoding #{filename} into JSON #{times} times\n\n"
Benchmark.bm { |x|
  x.report {
    puts "Yajl::Stream.encode"
    times.times {
      Yajl::Stream.encode(hash, StringIO.new)
    }
  }
  x.report {
    puts "JSON's #to_json"
    times.times {
      JSON.generate(hash)
    }
  }
}

# YAML Section
filename = 'benchmark/subjects/contacts.yml'
yml = File.new(filename, 'r')
data = YAML.load_stream(yml)
yml.close

times = ARGV[0] ? ARGV[0].to_i : 1
puts "Starting benchmark encoding #{filename} into YAML #{times} times\n\n"
Benchmark.bm { |x|
  x.report {
    puts "YAML.dump"
    times.times {
      YAML.dump(data, StringIO.new)
    }
  }
}
