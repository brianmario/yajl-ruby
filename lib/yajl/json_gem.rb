# encoding: UTF-8
require 'yajl' unless defined?(Yajl::Parser)

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

class Object
  def to_json(encoder=nil)
    encoder = Yajl::Encoder.new if encoder.nil?
    Yajl::Encoder.encode_string(encoder, self.to_s)
  end
end

class Hash
  def to_json(encoder=nil)
    encoder = Yajl::Encoder.new if encoder.nil?
    out = ''
    out << Yajl::Encoder.encode_hash_start(encoder)
    self.keys.map do |key|
      out << Yajl::Encoder.encode_hash_key(encoder, key.to_s)
      out << self[key].to_json(encoder)
    end
    out << Yajl::Encoder.encode_hash_end(encoder)
    out
  end
end

class Array
  def to_json(encoder=nil)
    encoder = Yajl::Encoder.new if encoder.nil?
    out = ''
    out << Yajl::Encoder.encode_array_start(encoder)
    self.map{ |val| out << val.to_json(encoder) }
    out << Yajl::Encoder.encode_array_end(encoder)
    out
  end
end

class Integer
  def to_json(encoder=nil)
    encoder = Yajl::Encoder.new if encoder.nil?
    Yajl::Encoder.encode_number(encoder, self.to_s)
  end
end

class Float
  def to_json(encoder=nil)
    encoder = Yajl::Encoder.new if encoder.nil?
    Yajl::Encoder.encode_number(encoder, self.to_s)
  end
end

class String
  def to_json(encoder=nil)
    encoder = Yajl::Encoder.new if encoder.nil?
    Yajl::Encoder.encode_string(encoder, self)
  end
end

class TrueClass
  def to_json(encoder=nil)
    encoder = Yajl::Encoder.new if encoder.nil?
    Yajl::Encoder.encode_boolean(encoder, true)
  end
end

class FalseClass
  def to_json(encoder=nil)
    encoder = Yajl::Encoder.new if encoder.nil?
    Yajl::Encoder.encode_boolean(encoder, false)
  end
end

class NilClass
  def to_json(encoder=nil)
    encoder = Yajl::Encoder.new if encoder.nil?
    Yajl::Encoder.encode_null(encoder)
  end
end