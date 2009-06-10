# encoding: UTF-8
require 'yajl' unless defined?(Yajl::Parser)

Yajl::Encoder.enable_json_gem_compatability

module JSON
  def self.parse(str, opts={})
    Yajl::Parser.parse(str, :symbolize_keys => false)
  end
  
  def self.generate(obj, opts={})
    options_map = {}
    if opts.has_key?(:indent)
      options_map[:pretty] = true
      options_map[:indent] = opts[:indent]
    end
    Yajl::Encoder.encode(obj, options_map)
  end
  
  def self.pretty_generate(obj, opts={})
    options_map = {}
    options_map[:pretty] = true
    options_map[:indent] = opts[:indent] if opts.has_key?(:indent)
    Yajl::Encoder.encode(obj, options_map)
  end
  
  def self.load(input, *args)
    Yajl::Parser.parse(input)
  end
  
  def self.dump(obj, io=nil, *args)
    Yajl::Encoder.encode(obj, io)
  end
end