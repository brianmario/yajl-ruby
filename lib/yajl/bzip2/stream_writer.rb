# encoding: UTF-8
module Yajl
  module Bzip2
    # === Yajl::Bzip2::StreamWriter
    class StreamWriter < ::Bzip2::Writer
      def self.encode(obj, io)
        Yajl::Stream.encode(obj, new(io))
      end
    end
  end
end