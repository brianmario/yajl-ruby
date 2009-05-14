# encoding: UTF-8
module Yajl
  module Deflate
    # === Yajl::Deflate::StreamWriter
    class StreamWriter < ::Zlib::Deflate
      def write(str)
        deflate(str)
        str.size unless str.nil?
      end
      
      def self.encode(obj, io)
        Yajl::Stream.encode(obj, new(io))
      end
    end
  end
end