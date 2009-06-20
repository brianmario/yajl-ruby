# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl_ext'
require 'stringio'
require 'json'
# Can't use ActiveSuport::JSON.encode with the JSON gem loaded
# require 'activesupport'

filename = ARGV[0] || 'benchmark/subjects/ohai.json'
json = File.new(filename, 'r')
hash = Yajl::Parser.new.parse(json)
json.close

times = ARGV[1] ? ARGV[1].to_i : 1
puts "Starting benchmark encoding #{filename} #{times} times\n\n"
Benchmark.bm { |x|
  io_encoder = Yajl::Encoder.new
  x.report {
    puts "Yajl::Encoder#encode (to an IO)"
    times.times {
      io_encoder.encode(hash, StringIO.new)
    }
  }
  string_encoder = Yajl::Encoder.new
  x.report {
    puts "Yajl::Encoder#encode (to a String)"
    times.times {
      output = string_encoder.encode(hash)
    }
  }
  x.report {
    puts "JSON's #to_json"
    times.times {
      JSON.generate(hash)
    }
  }
  # Can't use ActiveSuport::JSON.encode with the JSON gem loaded
  #
  # x.report {
  #   puts "ActiveSupport::JSON.encode"
  #   times.times {
  #     ActiveSupport::JSON.encode(hash)
  #   }
  # }
}
