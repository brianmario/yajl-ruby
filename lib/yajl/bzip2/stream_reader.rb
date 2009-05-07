# encoding: UTF-8
module Yajl
  module Bzip2
    # === Yajl::Bzip2::StreamReader
    #
    # This is a wrapper around Bzip::Reader to allow it's #read method to adhere
    # to the IO spec, allowing for two parameters (length, and buffer)
    class StreamReader < ::Bzip2::Reader
      def read(len=nil, buffer=nil)
        buffer.gsub!(/.*/, '') unless buffer.nil?
        buffer << super(len) and return unless buffer.nil?
        super(len)
      end

      def self.parse(io)
        Yajl::Stream.parse(new(io))
      end
    end
  end
end