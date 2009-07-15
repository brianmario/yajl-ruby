# encoding: UTF-8
require 'yajl' unless defined?(Yajl::Parser)

# NOTE: this is probably temporary until I can split out the JSON compat C code into it's own
# extension that can be included when this file is.
Yajl::Encoder.enable_json_gem_compatability

# Our fallback to_json definition
class Object
  def to_json(*args, &block)
    to_s
  end
end

module JSON
  def self.generate(obj, opts={})
    begin
      options_map = {}
      if opts.has_key?(:indent)
        options_map[:pretty] = true
        options_map[:indent] = opts[:indent]
      end
      Yajl::Encoder.encode(obj, options_map)
    rescue Yajl::ParseError => e
      raise JSON::ParserError, e.message
    end
  end
  
  def self.pretty_generate(obj, opts={})
    begin
      options_map = {}
      options_map[:pretty] = true
      options_map[:indent] = opts[:indent] if opts.has_key?(:indent)
      Yajl::Encoder.encode(obj, options_map)
    rescue Yajl::ParseError => e
      raise JSON::ParserError, e.message
    end
  end
  
  def self.dump(obj, io=nil, *args)
    begin
      Yajl::Encoder.encode(obj, io)
    rescue Yajl::ParseError => e
      raise JSON::ParserError, e.message
    end
  end
end