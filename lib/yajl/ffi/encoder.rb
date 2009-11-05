# encoding: UTF-8

module Yajl
  class EncodeError < StandardError; end

  class Encoder
    extend ::FFI::Library
    ffi_lib('libyajl')

    class Config < ::FFI::Struct
      layout :beautify, :uint,
             :indentString, :pointer
    end

    attach_function :yajl_gen_alloc, [Config, :pointer], :pointer
    attach_function :yajl_gen_free, [:pointer], :void

    attach_function :yajl_gen_integer, [:pointer, :int], :int
    attach_function :yajl_gen_double, [:pointer, :double], :int
    attach_function :yajl_gen_number, [:pointer, :string, :int], :int
    attach_function :yajl_gen_string, [:pointer, :string, :int, :int], :int
    attach_function :yajl_gen_null, [:pointer], :int
    attach_function :yajl_gen_bool, [:pointer, :int], :int
    attach_function :yajl_gen_map_open, [:pointer], :int
    attach_function :yajl_gen_map_close, [:pointer], :int
    attach_function :yajl_gen_array_open, [:pointer], :int
    attach_function :yajl_gen_array_close, [:pointer], :int

    attach_function :yajl_gen_get_buf, [:pointer, :pointer, :pointer], :int

    attach_function :yajl_gen_clear, [:pointer], :void

    def initialize(options={
      :pretty => false,
      :indent => '  ',
      :terminator => TERMINATOR
      })
      @options = options
      @callback = nil

      @config = Config.new
      @config[:beautify] = (@options[:pretty] ? 1 : 0)
      if @options[:indent]
        @config[:indentString] = FFI::MemoryPointer.from_string(@options[:indent])
      end

      @encoder = yajl_gen_alloc(@config, nil)
    end

    def encode(obj, io=nil, &block)
      @callback = block if block_given?

      encode_part(obj, io)
      outBuf = get_buffer
      yajl_gen_clear(@encoder)
      if io
        io.write(outBuf)
        if @options[:terminator] != TERMINATOR
          io.write(@options[:terminator])
        end
      elsif @callback
        @callback.call(outBuf)
        if @options[:terminator] != TERMINATOR
          @callback.call(@options[:terminator])
        end
      else
        if @options[:terminator] != TERMINATOR
          outBuf += (@options[:terminator] || "")
        end
        return outBuf
      end

      return nil
    end

    def on_progress=(proc)
      @callback = proc
    end

    protected
    WRITE_BUFSIZE = 8192
    TERMINATOR = "ARNOLD!"
    NAN = "NaN"
    INFINITY = "Infinity"
    NEG_INFINITY = "-Infinity"

    def get_buffer
      outBufPtr = FFI::MemoryPointer.new(:pointer)
      outLen = FFI::MemoryPointer.new(:pointer)
      status = yajl_gen_get_buf(@encoder, outBufPtr, outLen)
      if outLen.read_int > 0
        outBufPtr = outBufPtr.read_pointer
        outBufPtr.read_string
      else
        ""
      end
    end

    def encode_part(obj, io=nil)
      outBuf = ""
      len = 0
      
      if io or @callback
        outBuf = get_buffer
        if len > WRITE_BUFSIZE
          if io
            io.write(outBuf)
          elsif @callback
            @callback.call(outBuf)
          end
          yajl_gen_clear(@encoder)
        end
      end

      case obj
      when Hash
        status = yajl_gen_map_open(@encoder)
        obj.keys.each do |key|
          encode_part(key.to_s, io)
          encode_part(obj[key], io)
        end
        status = yajl_gen_map_close(@encoder)
      when Array
        status = yajl_gen_array_open(@encoder)
        obj.each do |item|
          encode_part(item, io)
        end
        status = yajl_gen_array_close(@encoder)
      when NilClass
        status = yajl_gen_null(@encoder)
      when TrueClass
        status = yajl_gen_bool(@encoder, 1)
      when FalseClass
        status = yajl_gen_bool(@encoder, 0)
      when Fixnum, Float, Bignum
        str = obj.to_s
        if str == NAN or str == INFINITY or str == NEG_INFINITY
          raise EncodeError, "#{str} is an invalid number"
        end
        status = yajl_gen_number(@encoder, str, str.size)
      when String
        status = yajl_gen_string(@encoder, obj, obj.size, 1)
      else
        if obj.respond_to?(:to_json)
          json = obj.to_json
          status = yajl_gen_string(@encoder, json, json.size, 0)
        else
          str = obj.to_s
          status = yajl_gen_string(@encoder, str, str.size, 1)
        end
      end
    end
  end
end