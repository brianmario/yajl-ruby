$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'benchmark'
require 'yajl'
begin
  require 'json'
rescue LoadError
end
require 'yaml'

# JSON Section
filename = 'benchmark/subjects/ohai.json'
json = File.new(filename, 'r')
hash = Yajl::Parser.new.parse(json)
json.close

times = ARGV[0] ? ARGV[0].to_i : 1000
puts "Starting benchmark encoding #{filename} into JSON #{times} times\n\n"
Benchmark.bmbm { |x|
  encoder = Yajl::Encoder.new
  x.report {
    puts "Yajl::Encoder#encode"
    times.times {
      encoder.encode(hash, File.open(File::NULL, 'w'))
    }
  }
  if defined?(JSON)
    x.report {
      puts "JSON's #to_json"
      times.times {
        JSON.generate(hash)
      }
    }
  end
}

# YAML Section
filename = 'benchmark/subjects/ohai.yml'
yml = File.new(filename, 'r')
data = YAML.load_stream(yml)
yml.close

puts "Starting benchmark encoding #{filename} into YAML #{times} times\n\n"
Benchmark.bmbm { |x|
  x.report {
    puts "YAML.dump"
    times.times {
      YAML.dump(data, File.open(File::NULL, 'w'))
    }
  }
}
