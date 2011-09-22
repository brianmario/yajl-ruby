# = Yajl
#
# Ruby bindings to the excellent Yajl (Yet Another JSON Parser) ANSI C library.
module Yajl
  class Parser
    # A helper method for parse-and-forget use-cases
    #
    # +io+ is the stream to parse JSON from
    #
    # The +options+ hash allows you to set two parsing options - :allow_comments and :check_utf8
    #
    # :allow_comments accepts a boolean will enable/disable checks for in-line comments in the JSON stream
    #
    # :check_utf8 accepts a boolean will enable/disable UTF8 validation for the JSON stream
    def self.parse(str_or_io, options={}, read_bufsize=nil, &block)
      new(options).parse(str_or_io, read_bufsize, &block)
    end
  end
end