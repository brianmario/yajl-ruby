# encoding: UTF-8

module Yajl
  class Parser
    extend ::FFI::Library
    ffi_lib('libyajl')
    
    attach_function :yajl_status_to_string, [:int], :string
    
    callback :yajl_null_cb, [:pointer], :int
    callback :yajl_boolean_cb, [:pointer, :int], :int
    callback :yajl_integer_cb, [:pointer, :long], :int
    callback :yajl_double_cb, [:pointer, :double], :int
    callback :yajl_number_cb, [:pointer, :pointer, :uint], :int
    callback :yajl_string_cb, [:pointer, :pointer, :uint], :int
    callback :yajl_start_map_cb, [:pointer], :int
    callback :yajl_map_key_cb, [:pointer, :pointer, :uint], :int
    callback :yajl_end_map_cb, [:pointer], :int
    callback :yajl_start_array_cb, [:pointer], :int
    callback :yajl_end_array_cb, [:pointer], :int

    # Now, reopen our structs and define them
    # The reason we do this is because the functions above need to be defined before
    # we can use them inside the struct (specifically the Callbacks struct)
    class Callbacks < ::FFI::Struct
      layout :yajl_null, :yajl_null_cb,
             :yajl_boolean, :yajl_boolean_cb,
             :yajl_integer, :yajl_integer_cb,
             :yajl_double, :yajl_double_cb,
             :yajl_number, :yajl_number_cb,
             :yajl_string, :yajl_string_cb,
             :yajl_start_map, :yajl_start_map_cb,
             :yajl_map_key, :yajl_map_key_cb,
             :yajl_end_map, :yajl_end_map_cb,
             :yajl_start_array, :yajl_start_array_cb,
             :yajl_end_array, :yajl_end_array_cb
    end
    
    class Config < ::FFI::Struct
      layout :allowComments, :uint,
             :checkUTF8, :uint
    end
    
    attach_function :yajl_alloc, [Callbacks, Config, :pointer, :pointer], :pointer
    # attach_function :yajl_reset_parser, [:pointer], :void
    attach_function :yajl_free, [:pointer], :void
    attach_function :yajl_parse, [:pointer, :string, :uint], :int
    attach_function :yajl_parse_complete, [:pointer], :int
    attach_function :yajl_get_error, [:pointer, :int, :string, :uint], :string
    attach_function :yajl_free_error, [:pointer, :string], :void
  end
end