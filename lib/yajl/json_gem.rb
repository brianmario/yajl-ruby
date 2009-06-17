# encoding: UTF-8
require 'yajl' unless defined?(Yajl::Parser)

# NOTE: this is probably temporary until I can split out the JSON compat C code into it's own
# extension that can be included when this file is.
Yajl::Encoder.enable_json_gem_compatability

module JSON
  
  class ParserError < Yajl::ParseError; end
  
  def self.parse(str, opts={})
    begin
      Yajl::Parser.parse(str, opts)
    rescue Yajl::ParseError => e
      raise JSON::ParserError, e.message
    end
  end
  
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
  
  def self.load(input, *args)
    begin
      Yajl::Parser.parse(input)
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

module ::Kernel
  def JSON(object, opts = {})
    if object.respond_to? :to_s
      JSON.parse(object.to_s, opts)
    else
      JSON.generate(object, opts)
    end
  end
end