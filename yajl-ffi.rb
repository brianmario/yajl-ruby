require 'rubygems'
require 'ffi'

module Yajl
  class FFI
    extend ::FFI::Library
    ffi_lib('libyajl')
    
    class Config < ::FFI::Struct; end
    class Callbacks < ::FFI::Struct; end
    
    callback :yajl_null_func, [:pointer], :int
    callback :yajl_boolean_func, [:pointer, :int], :int
    callback :yajl_integer_func, [:pointer, :long], :int
    callback :yajl_double_func, [:pointer, :double], :int
    callback :yajl_number_func, [:pointer, :pointer, :uint], :int
    callback :yajl_string_func, [:pointer, :pointer, :uint], :int
    callback :yajl_start_map_func, [:pointer], :int
    callback :yajl_map_key_func, [:pointer, :pointer, :uint], :int
    callback :yajl_end_map_func, [:pointer], :int
    callback :yajl_start_array_func, [:pointer], :int
    callback :yajl_end_array_func, [:pointer], :int
    
    attach_function :yajl_status_to_string, [:int], :string
    attach_function :yajl_alloc, [Callbacks, Config, :pointer, :pointer], :pointer
    attach_function :yajl_free, [:pointer], :void
    attach_function :yajl_parse, [:pointer, :string, :uint], :int
    attach_function :yajl_parse_complete, [:pointer], :int
    attach_function :yajl_get_error, [:pointer, :int, :string, :uint], :string
    attach_function :yajl_free_error, [:pointer, :string], :void
    
    class Config < ::FFI::Struct
      layout :allowComments, :uint,
        :checkUTF8, :uint
    end

    class Callbacks < ::FFI::Struct
      layout :yajl_null, :yajl_null_func,
        :yajl_boolean, :yajl_boolean_func,
        :yajl_integer, :yajl_integer_func,
        :yajl_double, :yajl_double_func,
        :yajl_number, :yajl_number_func,
        :yajl_string, :yajl_string_func,
        :yajl_start_map, :yajl_start_map_func,
        :yajl_map_key, :yajl_map_key_func,
        :yajl_end_map, :yajl_end_map_func,
        :yajl_start_array, :yajl_start_array_func,
        :yajl_end_array, :yajl_end_array_func
    end
    
    def self.parse(io)
      # setup a new parser
      parser = self.new
      parser.parse(io)
    end
    
    def initialize
      @params = []
    end
    
    def found_null(ctx)
      # puts "Found a null"
      return 1
    end
    
    def found_boolean(ctx, bool)
      # puts "Found a boolean: #{!!bool}"
      @params << !!bool
      return 1
    end
    
    def found_number(ctx, number_buf, len)
      # puts "Found a number: #{number[0,len]}"
      number = number_buf.get_bytes(0,len)
      @params << number
      return 1
    end
    
    def found_string(ctx, str_buf, len)
      # puts "Found a string: #{str[0,len]}"
      str = str_buf.get_bytes(0,len)
      @params << str
      return 1
    end
    
    def found_hash_start(ctx)
      # puts "Found the beginning of a hash"
      return 1
    end
    
    def found_hash_key(ctx, str_buf, len)
      # puts "Found a hash key: #{str[0,len]}"
      str = str_buf.get_bytes(0,len)
      @params << str
      return 1
    end
    
    def found_hash_end(ctx)
      # puts "Found the end of a hash"
      return 1
    end
    
    def found_array_start(ctx)
      # puts "Found the beginning of an array"
      return 1
    end
    
    def found_array_end(ctx)
      # puts "Found the end of an array"
      return 1
    end
    
    def parse(io)
      # create our config
      config = Config.new
      config[:allowComments] = 1
      config[:checkUTF8] = 1

      # setup callbacks
      callbacks = Callbacks.new
      callbacks[:yajl_null] = method(:found_null)
      callbacks[:yajl_boolean] = method(:found_boolean)
      callbacks[:yajl_number] = method(:found_number)
      callbacks[:yajl_string] = method(:found_string)
      callbacks[:yajl_start_map] = method(:found_hash_start)
      callbacks[:yajl_map_key] = method(:found_hash_key)
      callbacks[:yajl_end_map] = method(:found_hash_end)
      callbacks[:yajl_start_array] = method(:found_array_start)
      callbacks[:yajl_end_array] = method(:found_array_end)

      parser = yajl_alloc(callbacks, config, nil, nil)

      bytes = ''
      while io.read(65536, bytes)
        status = yajl_parse(parser, bytes, bytes.size)
        GC.start
        if status != 0 && status != 2
          error = yajl_status_to_string(status)
          error_str = yajl_get_error(parser, 1, bytes, bytes.size)
          puts error_str
          yajl_free_error(parser, error_str)
          break
        end

      end

      yajl_parse_complete(parser)
      yajl_free(parser)
    end
  end
end