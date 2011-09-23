$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'benchmark'
require 'yaml'
require 'yajl'
require 'json'
require 'psych' if RUBY_VERSION =~ /1.9.2/
require 'active_support'

filename = ARGV[0] || 'benchmark/subjects/item.json'
json = File.new(filename, 'r')

times = ARGV[1] ? ARGV[1].to_i : 10_000
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bmbm { |x|
  io_parser = Yajl::Parser.new
  io_parser.on_parse_complete = lambda {|obj|} if times > 1
  x.report {
    puts "Yajl::Parser#parse (from an IO)"
    times.times {
      json.rewind
      io_parser.parse(json)
    }
  }
  string_parser = Yajl::Parser.new
  string_parser.on_parse_complete = lambda {|obj|} if times > 1
  x.report {
    puts "Yajl::Parser#parse (from a String)"
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
  x.report {
    puts "YAML.load (from an IO)"
    times.times {
      json.rewind
      YAML.load(json)
    }
  }
  x.report {
    puts "YAML.load (from a String)"
    times.times {
      json.rewind
      YAML.load(json.read)
    }
  }
  if defined?(Psych)
    x.report {
      puts "Psych.load (from an IO)"
      times.times {
        json.rewind
        Psych.load(json)
      }
    }
    x.report {
      puts "Psych.load (from a String)"
      times.times {
        json.rewind
        Psych.load(json.read)
      }
    }
  end
}
json.close