# encoding: UTF-8
module Yajl
  module Gzip
    # === Yajl::GzipStreamReader
    #
    # This is a wrapper around Zlib::GzipReader to allow it's #read method to adhere
    # to the IO spec, allowing for two parameters (length, and buffer)
    class StreamReader < ::Zlib::GzipReader
      def read(len=nil, buffer=nil)
        unless buffer.nil?
          buffer.gsub!(/.*/, '')
          buffer << super(len)
          return buffer
        end
        super(len)
      end
      
      def self.parse(io)
        Yajl::Stream.parse(new(io))
      end
    end
  end
end