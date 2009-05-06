# encoding: UTF-8
require 'yajl.bundle'
require 'yajl/http_stream.rb' unless defined?(Yajl::HttpStream)

require 'zlib' unless defined?(Zlib)
require 'yajl/gzip/stream_reader.rb' unless defined?(Yajl::Gzip::StreamReader)

begin
  require 'bzip2' unless defined?(Bzip2)
  require 'yajl/bzip2/stream_reader.rb' unless defined?(Yajl::Bzip2::StreamReader)
rescue LoadError => e
  # that's ok, we'll just continue without Bzip2 support
end

# = Yajl
#
# Ruby bindings to the excellent Yajl (Yet Another JSON Parser) ANSI C library.
module Yajl
  VERSION = "0.4.3"
  
  # == Yajl::Chunked
  #
  # This module contains methods for parsing JSON in chunks.
  # The use case here is that the caller may not be able to get access to the IO to which
  # JSON content is being received. Rendering Yajl::Stream dead to them.
  #
  # With the methods in this module, the caller will be able to pass in chunks of JSON content
  # until a full object has been parsed from said content.
  #
  # In order for this process to work correctly, the caller needs to specify a callback which
  # is passed the constructed object. The only requirement currently of this callback is that
  # it respond to #call and accept a single parameter (the object that was created from parsing).
  module Chunked; end
  
  # == Yajl::Stream
  #
  # This module contains methods for parsing JSON directly from an IO object.
  #
  # The only basic requirment currently is that the IO object respond to #read(len) and eof?
  #
  # The IO is parsed until a complete JSON object has been read and a ruby object will be returned.
  module Stream; end
end