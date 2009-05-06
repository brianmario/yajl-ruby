module Yajl
  module Gzip
    # === Yajl::GzipStreamReader
    #
    # This is a wrapper around Zlib::GzipReader to allow it's #read method to adhere
    # to the IO spec, allowing for two parameters (length, and buffer)
    class StreamReader < ::Zlib::GzipReader
      def read(len=nil, buffer=nil)
        buffer.gsub!(/.*/, '') unless buffer.nil?
        buffer << super(len) and return unless buffer.nil?
        super(len)
      end
    end
  end
end