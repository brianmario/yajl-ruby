# encoding: UTF-8

require 'yajl.rb' unless defined?(Yajl::Stream)
require 'zlib' unless defined?(Zlib)
require 'yajl/gzip/stream_reader.rb'