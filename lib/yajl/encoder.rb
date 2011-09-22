module Yajl
  class Encoder
    # A helper method for encode-and-forget use-cases
    #
    # Examples:
    #   Yajl::Encoder.encode(obj[, io, :pretty => true, :indent => "\t", &block])
    #
    #   output = Yajl::Encoder.encode(obj[, :pretty => true, :indent => "\t", &block])
    #
    # +obj+ is a ruby object to encode to JSON format
    #
    # +io+ is the optional IO stream to encode the ruby object to.
    # If +io+ isn't passed, the resulting JSON string is returned. If +io+ is passed, nil is returned.
    #
    # The +options+ hash allows you to set two encoding options - :pretty and :indent
    #
    # :pretty accepts a boolean and will enable/disable "pretty printing" the resulting output
    #
    # :indent accepts a string and will be used as the indent character(s) during the pretty print process
    #
    # If a block is passed, it will be used as (and work the same as) the +on_progress+ callback
    def self.encode(obj, *args, &block)
      # TODO: this code smells, any ideas?
      args.flatten!
      options = {}
      io = nil
      args.each do |arg|
        if arg.is_a?(Hash)
          options = arg
        elsif arg.respond_to?(:read)
          io = arg
        end
      end if args.any?
      new(options).encode(obj, io, &block)
    end
  end
end