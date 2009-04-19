require 'rubygems'

require 'benchmark'
require 'yajl.bundle'
require 'yajl-ffi'
require 'json'
require 'activesupport'

filename = ARGV[0] || 'item.json'
json = File.new(filename, File::RDONLY | File::NONBLOCK)

times = ARGV[1] ? ARGV[1].to_i : 1000
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bm { |x|
  x.report {
    puts "Yajl::Native.parse (C)"
    times.times {
      json.rewind
      Yajl::Native.parse(json)
    }
  }
  x.report {
    puts "\nJSON.parser"
    times.times {
      json.rewind
      JSON.parse(json.read)
    }
  }
  x.report {
    puts "\nActiveSupport::JSON.decode"
    times.times {
      json.rewind
      ActiveSupport::JSON.decode(json.read)
    }
  }
  x.report {
    puts "\nYajl::FFI.parse"
    times.times {
      json.rewind
      Yajl::FFI.parse(json, nil)
    }
  }
}
json.close