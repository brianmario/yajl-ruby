require 'yajl/yajl'
require 'yajl/encoder'
require 'yajl/parser'

# = Yajl
#
# Ruby bindings to the excellent Yajl (Yet Another JSON Parser) ANSI C library.
module Yajl
  # For compatibility, has the same signature of Yajl::Parser.parse
  def self.load(str_or_io, options={}, read_bufsize=nil, &block)
    Parser.parse(str_or_io, options, read_bufsize, &block)
  end

  # For compatibility, has the same signature of Yajl::Encoder.encode
  def self.dump(obj, *args, &block)
    Encoder.encode(obj, args, &block)
  end
end