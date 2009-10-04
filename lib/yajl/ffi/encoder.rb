# encoding: UTF-8

module Yajl
  class Encoder
    extend ::FFI::Library
    ffi_lib('libyajl')
    
    class Config < ::FFI::Struct
      layout :beautify, :uint,
             :indentString, :string
    end
    
    attach_function :yajl_gen_alloc, [Config, :pointer], :pointer
    attach_function :yajl_gen_free, [:pointer], :void
    
    attach_function :yajl_gen_integer, [:pointer, :int], :int
    attach_function :yajl_gen_double, [:pointer, :double], :int
    attach_function :yajl_gen_number, [:pointer, :string, :int], :int
    attach_function :yajl_gen_string, [:pointer, :string, :int], :int
    attach_function :yajl_gen_null, [:pointer], :int
    attach_function :yajl_gen_bool, [:pointer, :int], :int
    attach_function :yajl_gen_map_open, [:pointer], :int
    attach_function :yajl_gen_map_close, [:pointer], :int
    attach_function :yajl_gen_array_open, [:pointer], :int
    attach_function :yajl_gen_array_close, [:pointer], :int
    
    attach_function :yajl_gen_get_buf, [:pointer, :string, :int], :int
    
    attach_function :yajl_gen_clear, [:pointer], :void
  end
end