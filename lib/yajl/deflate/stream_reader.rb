# encoding: UTF-8
module Yajl
  module Deflate
    # === Yajl::Deflate::StreamReader
    #
    # This is a wrapper around Zlib::Inflate, creating a #read method that adheres
    # to the IO spec, allowing for two parameters (length, and buffer)
    class StreamReader < ::Zlib::Inflate
      def initialize(io, options)
        @io = io
        super(options)
      end
      
      def read(len=nil, buffer=nil)
        buffer.replace inflate(@io.read(len)) and return unless buffer.nil?
        inflate(@io.read(len))
      end
      
      alias :eof? :finished?
      
      def self.parse(io, options=nil)
        Yajl::Parser.new.parse(new(io, options))
      end
    end
  end
end