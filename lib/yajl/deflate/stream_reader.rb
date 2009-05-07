# encoding: UTF-8
module Yajl
  module Deflate
    # === Yajl::Deflate::StreamReader
    #
    # This is a wrapper around Zlib::Inflate, creating a #read method that adheres
    # to the IO spec, allowing for two parameters (length, and buffer)
    class StreamReader < ::Zlib::Inflate
      def initialize(io)
        @io = io
        super(nil)
      end
      
      def read(len=nil, buffer=nil)
        buffer.gsub!(/.*/, '') unless buffer.nil?
        buffer << inflate(@io.read(len)) and return unless buffer.nil?
        inflate(@io.read(len))
      end
      
      alias :eof? :finished?
      
      def self.parse(io)
        Yajl::Stream.parse(new(io))
      end
    end
  end
end