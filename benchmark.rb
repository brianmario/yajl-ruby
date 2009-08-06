require 'rubygems'

require 'benchmark'
require 'yajl-ffi'
# require 'json'
# require 'activesupport'

filename = ARGV[0] || 'json/search.json'
json = File.new(filename, File::RDONLY | File::NONBLOCK)

times = ARGV[1] ? ARGV[1].to_i : 1
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bm { |x|
  x.report {
    puts "Yajl::FFI.parse (C)"
    times.times {
      # json.rewind
      Yajl::FFI.parse(json)
    }
  }
  # x.report {
  #     puts "\nJSON.parser"
  #     times.times {
  #       json.rewind
  #       JSON.parse(json.read, :max_nesting => false)
  #     }
  #   }
  #   x.report {
  #     puts "\nActiveSupport::JSON.decode"
  #     times.times {
  #       json.rewind
  #       ActiveSupport::JSON.decode(json.read)
  #     }
  #   }
  }
json.close