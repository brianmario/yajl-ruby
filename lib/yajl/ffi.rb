# encoding: UTF-8
require 'ffi'
require 'yajl/ffi/parser'
require 'yajl/ffi/encoder'

module Yajl
  # class Parser
  #   def self.parse(str_or_io)
  #     # setup a new parser
  #     parser = self.new
  #     parser.parse(str_or_io)
  #   end
  # 
  #   def initialize
  #     @params = []
  # 
  #     # create our config
  #     @config = Config.new
  #     @config[:allowComments] = 1
  #     @config[:checkUTF8] = 1
  # 
  #     # setup callbacks
  #     callbacks = Callbacks.new
  #     callbacks[:yajl_null] = method(:found_null)
  #     callbacks[:yajl_boolean] = method(:found_boolean)
  #     callbacks[:yajl_number] = method(:found_number)
  #     callbacks[:yajl_string] = method(:found_string)
  #     callbacks[:yajl_start_map] = method(:found_hash_start)
  #     callbacks[:yajl_map_key] = method(:found_hash_key)
  #     callbacks[:yajl_end_map] = method(:found_hash_end)
  #     callbacks[:yajl_start_array] = method(:found_array_start)
  #     callbacks[:yajl_end_array] = method(:found_array_end)
  # 
  #     @parser = yajl_alloc(callbacks, @config, nil, nil)
  #   end
  # 
  #   def found_null(ctx)
  #     # puts "Found a null"
  #     return 1
  #   end
  # 
  #   def found_boolean(ctx, bool)
  #     # puts "Found a boolean: #{!!bool}"
  #     @params << !!bool
  #     return 1
  #   end
  # 
  #   def found_number(ctx, number_buf, len)
  #     # puts "Found a number: #{number[0,len]}"
  #     number = number_buf.get_bytes(0,len)
  #     @params << number
  #     return 1
  #   end
  # 
  #   def found_string(ctx, str_buf, len)
  #     # puts "Found a string: #{str[0,len]}"
  #     str = str_buf.get_bytes(0,len)
  #     @params << str
  #     return 1
  #   end
  # 
  #   def found_hash_start(ctx)
  #     # puts "Found the beginning of a hash"
  #     return 1
  #   end
  # 
  #   def found_hash_key(ctx, str_buf, len)
  #     # puts "Found a hash key: #{str[0,len]}"
  #     str = str_buf.get_bytes(0,len)
  #     @params << str
  #     return 1
  #   end
  # 
  #   def found_hash_end(ctx)
  #     # puts "Found the end of a hash"
  #     return 1
  #   end
  # 
  #   def found_array_start(ctx)
  #     # puts "Found the beginning of an array"
  #     return 1
  #   end
  # 
  #   def found_array_end(ctx)
  #     # puts "Found the end of an array"
  #     return 1
  #   end
  # 
  #   def parse(str_or_io)
  #     if str_or_io.is_a?(String)
  #       status = yajl_parse(@parser, str_or_io, str_or_io.size)
  #       check_status(status, str_or_io)
  #     else
  #       bytes = ''
  #       while str_or_io.read(8192, bytes)
  #         status = yajl_parse(@parser, bytes, bytes.size)
  #         check_status(status, bytes)
  #       end
  #     end
  # 
  #     yajl_parse_complete(@parser)
  #     yajl_free(@parser)
  #   end
  # 
  #   def check_status(status, bytes)
  #     if status != 0 && status != 2
  #       error = yajl_status_to_string(status)
  #       error_str = yajl_get_error(@parser, 1, bytes, bytes.size)
  #       puts error_str
  #       yajl_free_error(@parser, error_str)
  #       break
  #     end
  #   end
  # end
end