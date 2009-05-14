# encoding: UTF-8

require 'yajl.rb' unless defined?(Yajl::Stream)
require 'zlib' unless defined?(Zlib)
require 'yajl/deflate/stream_reader.rb'
require 'yajl/deflate/stream_writer.rb'