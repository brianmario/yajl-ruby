# encoding: UTF-8
require 'rubygems'
require 'benchmark'
require 'yajl_ext'
require 'json'
# Can't use ActiveSuport::JSON.encode with the JSON gem loaded
# require 'activesupport'

filename = ARGV[0] || 'benchmark/subjects/contacts.json'
json = File.new(filename, 'r')
hash = Yajl::Parser.new.parse(json)
json.close

times = ARGV[1] ? ARGV[1].to_i : 1
puts "Starting benchmark encoding #{filename} #{times} times\n\n"
Benchmark.bm { |x|
  encoder = Yajl::Encoder.new
  x.report {
    puts "Yajl::Encoder#encode"
    times.times {
      encoder.encode(hash, StringIO.new)
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
