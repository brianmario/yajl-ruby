# encoding: UTF-8
require 'yajl_ext'

# = Extras
# We're not going to load these auotmatically, because you might not need them ;)
#
# require 'yajl/http_stream.rb' unless defined?(Yajl::HttpStream)
# require 'yajl/gzip.rb' unless defined?(Yajl::Gzip)
# require 'yajl/deflate.rb' unless defined?(Yajl::Deflate)
# require 'yajl/bzip2.rb' unless defined?(Yajl::Bzip2)

# = Yajl
#
# Ruby bindings to the excellent Yajl (Yet Another JSON Parser) ANSI C library.
module Yajl
  VERSION = "0.5.1"
  
  # == Yajl::Parser
  #
  # This module contains methods for parsing JSON directly from an IO object.
  #
  # The only basic requirment currently is that the IO object respond to #read(len) and eof?
  #
  # The IO is parsed until a complete JSON object has been read and a ruby object will be returned.
  class Parser; end
  
  # Deprecated
  module Stream
    # Deprecated
    def self.parse(io)
      STDERR.puts "WARNING: Yajl::Stream has be deprecated and will most likely be gone in the next release. Use the Yajl::Parser class instead."
      Parser.new.parse(io)
    end
    
    # Deprecated
    def self.encode(obj, io)
      STDERR.puts "WARNING: Yajl::Stream has be deprecated and will most likely be gone in the next release. Use the Yajl::Encoder class instead."
      Encoder.new.encode(obj, io)
    end
  end
end