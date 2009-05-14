# encoding: UTF-8
module Yajl
  module Gzip
    # === Yajl::Gzip::StreamWriter
    class StreamWriter < ::Zlib::GzipWriter
      def self.encode(obj, io)
        Yajl::Stream.encode(obj, new(io))
      end
    end
  end
end