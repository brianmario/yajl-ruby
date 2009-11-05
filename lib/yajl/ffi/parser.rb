# encoding: UTF-8

module Yajl
  class ParseError < StandardError; end
  
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
    begin
      attach_function :yajl_reset_parser, [:pointer], :void
    rescue FFI::NotFoundError
      raise LoadError, "You must be using the yajl-ruby branch in brianmario's fork of Yajl for continuous stream parsing and encoding. You can download it from: http://github.com/brianmario/yajl"
    end
    attach_function :yajl_free, [:pointer], :void
    attach_function :yajl_parse, [:pointer, :string, :uint], :int
    attach_function :yajl_parse_complete, [:pointer], :int
    attach_function :yajl_get_error, [:pointer, :int, :string, :uint], :string
    attach_function :yajl_free_error, [:pointer, :string], :void
    
    def initialize(options={
      :symbolize_keys => false,
      :allow_comments => false,
      :check_utf8 => false
    })
      @builder_stack = []
      @nested_array_level = 0
      @nested_hash_level = 0
      @objects_found = 0
      @callback = nil
      @options = options
      
      # create our config
      @config = Config.new
      @config[:allowComments] = (@options[:allow_comments] ? 1 : 0)
      @config[:checkUTF8] = (@options[:check_utf8] ? 1 : 0)

      # setup callbacks
      @callbacks = Callbacks.new
      @callbacks[:yajl_null] = method(:found_null)
      @callbacks[:yajl_boolean] = method(:found_boolean)
      @callbacks[:yajl_number] = method(:found_number)
      @callbacks[:yajl_string] = method(:found_string)
      @callbacks[:yajl_start_map] = method(:found_hash_start)
      @callbacks[:yajl_map_key] = method(:found_hash_key)
      @callbacks[:yajl_end_map] = method(:found_hash_end)
      @callbacks[:yajl_start_array] = method(:found_array_start)
      @callbacks[:yajl_end_array] = method(:found_array_end)

      @parser = yajl_alloc(@callbacks, @config, nil, nil)
    end
    
    def parse(str_or_io, buffer_size=8192, &block)
      @callback = block if block_given?
      
      if str_or_io.is_a?(String)
        status = yajl_parse(@parser, str_or_io, str_or_io.size)
        check_status(status, str_or_io)
      elsif str_or_io.respond_to?(:eof?)
        buf = ''
        until str_or_io.eof?
          str_or_io.read(buffer_size, buf)
          status = yajl_parse(@parser, buf, buf.size)
          check_status(status, buf)
        end
      else
        raise ParseError, "input must be a string or IO"
      end
      
      # How the hell am I gonna handle this in ruby? :P
      # (I want the parser instance to stay alive until this class instance is GC'd)
      # yajl_parse_complete(@parser)
      # yajl_free(@parser)
      
      if !@callback.nil?
        check_and_fire_callback
        return nil
      end
      
      @builder_stack.pop
    end
    
    def parse_chunk(str)
      raise ParseError, "The on_parse_complete callback isn't setup, parsing useless." if @callback.nil?
      status = yajl_parse(@parser, str, str.size)
      check_status(status, str)
    end
    alias :<< :parse_chunk
    
    def on_parse_complete=(cb)
      @callback = cb
    end
    
    protected
      def check_status(status, buffer)
        if status != 0 && status != 2
          begin
            error = yajl_status_to_string(status)
            error_str = yajl_get_error(@parser, 1, buffer, buffer.size)
            raise ParseError, error_str
          ensure
            yajl_free_error(@parser, error_str)
          end
        end
      end
      
      def check_and_fire_callback
        if @builder_stack.size == 1 && @nested_array_level == 0 && @nested_hash_level == 0
          if !@callback.nil?
            @callback.call(@builder_stack.pop)
          else
            @objects_found += 1
            if @objects_found > 1
              raise ParseError, "Found multiple JSON objects in the stream but no block or the on_parse_complete callback was assigned to handle them."
            end
          end
        end
      end
      
      def set_static_value(val)
        if @builder_stack.size > 0
          last_entry = @builder_stack.last
          case last_entry.class.name
          when "Array"
            last_entry.push val
            if val.is_a?(Hash) || val.is_a?(Array)
              @builder_stack.push val
            end
          when "Hash"
            last_entry[val] = nil
            @builder_stack.push val
          when "String", "Symbol"
            hash = @builder_stack[@builder_stack.size-2]
            if hash.is_a?(Hash)
              hash[last_entry] = val
              @builder_stack.pop
              if val.is_a?(Hash) || val.is_a?(Array)
                @builder_stack.push val
              end
            end
          end
        else
          @builder_stack.push val
        end
      end
      
      # Yajl Callbacks
      def found_null(ctx)
        set_static_value(nil)
        check_and_fire_callback
        return 1
      end

      def found_boolean(ctx, bool)
        set_static_value(!!bool)
        check_and_fire_callback
        return 1
      end

      def found_number(ctx, number_buf, len)
        number = number_buf.get_bytes(0,len)
        if number.include?('.') || number.include?('e') || number.include?('E')
          set_static_value(number.to_f)
        else
          set_static_value(number.to_i)
        end
        check_and_fire_callback
        return 1
      end

      def found_string(ctx, str_buf, len)
        str = str_buf.get_bytes(0,len)
        set_static_value(str)
        check_and_fire_callback
        return 1
      end

      def found_hash_key(ctx, str_buf, len)
        str = str_buf.get_bytes(0,len)
        if @options[:symbolize_keys]
          set_static_value(str.to_sym)
        else
          set_static_value(str)
        end
        check_and_fire_callback
        return 1
      end

      def found_hash_start(ctx)
        @nested_hash_level += 1
        set_static_value({})
        return 1
      end

      def found_hash_end(ctx)
        @nested_hash_level -= 1
        if @builder_stack.size > 1
          @builder_stack.pop
        end
        check_and_fire_callback
        return 1
      end

      def found_array_start(ctx)
        @nested_array_level += 1
        set_static_value([])
        return 1
      end

      def found_array_end(ctx)
        @nested_array_level -= 1
        if @builder_stack.size > 1
          @builder_stack.pop
        end
        check_and_fire_callback
        return 1
      end
  end
end