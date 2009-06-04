# encoding: UTF-8
module Yajl
  module Deflate
    # This is a wrapper around Zlib::Inflate, creating a #read method that adheres
    # to the IO spec, allowing for two parameters (length, and buffer)
    class StreamReader < ::Zlib::Inflate
      
      # Wrapper to the initialize method so we can set the initial IO to parse from.
      def initialize(io, options)
        @io = io
        super(options)
      end
      
      # A helper method to allow use similar to IO#read
      def read(len=nil, buffer=nil)
        buffer.replace inflate(@io.read(len)) and return unless buffer.nil?
        inflate(@io.read(len))
      end
      alias :eof? :finished?
      
      # Helper method for one-off parsing from a deflate-compressed stream
      #
      # See Yajl::Parser#parse for parameter documentation
      def self.parse(io, options={}, buffer_size=nil, &block)
        Yajl::Parser.new(options).parse(new(io, buffer_size, &block))
      end
    end
  end
end