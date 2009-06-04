#include "yajl_ext.h"

// Helpers for building objects
inline void yajl_check_and_fire_callback(void * ctx) {
    struct yajl_parser_wrapper * wrapper;
    GetParser((VALUE)ctx, wrapper);
    
    // No need to do any of this if the callback isn't even setup
    if (wrapper->parse_complete_callback != Qnil) {
        int len = RARRAY_LEN(wrapper->builderStack);
        if (len == 1 && wrapper->nestedArrayLevel == 0 && wrapper->nestedHashLevel == 0) {
            rb_funcall(wrapper->parse_complete_callback, intern_call, 1, rb_ary_pop(wrapper->builderStack));
        }
    } else {
        int len = RARRAY_LEN(wrapper->builderStack);
        if (len == 1 && wrapper->nestedArrayLevel == 0 && wrapper->nestedHashLevel == 0) {
            wrapper->objectsFound++;
            if (wrapper->objectsFound > 1) {
                rb_raise(cParseError, "%s", "Found multiple JSON objects in the stream but no block or the on_parse_complete callback was assigned to handle them.");
            }
        }
    }
}

inline void yajl_set_static_value(void * ctx, VALUE val) {
    struct yajl_parser_wrapper * wrapper;
    VALUE lastEntry, hash;
    int len;
    
    GetParser((VALUE)ctx, wrapper);
    
    len = RARRAY_LEN(wrapper->builderStack);
    if (len > 0) {
        lastEntry = rb_ary_entry(wrapper->builderStack, len-1);
        switch (TYPE(lastEntry)) {
            case T_ARRAY:
                rb_ary_push(lastEntry, val);
                if (TYPE(val) == T_HASH || TYPE(val) == T_ARRAY) {
                    rb_ary_push(wrapper->builderStack, val);
                }
                break;
            case T_HASH:
                rb_hash_aset(lastEntry, val, Qnil);
                rb_ary_push(wrapper->builderStack, val);
                break;
            case T_STRING:
                hash = rb_ary_entry(wrapper->builderStack, len-2);
                if (TYPE(hash) == T_HASH) {
                    rb_hash_aset(hash, lastEntry, val);
                    rb_ary_pop(wrapper->builderStack);
                    if (TYPE(val) == T_HASH || TYPE(val) == T_ARRAY) {
                        rb_ary_push(wrapper->builderStack, val);
                    }
                }
                break;
        }
    } else {
        rb_ary_push(wrapper->builderStack, val);
    }
}

void yajl_encode_part(yajl_gen hand, VALUE obj, VALUE io) {
    VALUE str, outBuff, otherObj;
    int objLen;
    int idx = 0;
    const unsigned char * buffer;
    unsigned int len;
    
    yajl_gen_get_buf(hand, &buffer, &len);
    if (len >= WRITE_BUFSIZE) {
        outBuff = rb_str_new((const char *)buffer, len);
        rb_io_write(io, outBuff);
        yajl_gen_clear(hand);
    }
    
    switch (TYPE(obj)) {
        case T_HASH:
            yajl_gen_map_open(hand);
            
            // TODO: itterate through keys in the hash
            VALUE keys = rb_funcall(obj, intern_keys, 0);
            VALUE entry;
            for(idx=0; idx<RARRAY_LEN(keys); idx++) {
                entry = rb_ary_entry(keys, idx);
                // the key
                yajl_encode_part(hand, entry, io);
                // the value
                yajl_encode_part(hand, rb_hash_aref(obj, entry), io);
            }
            
            yajl_gen_map_close(hand);
            break;
        case T_ARRAY:
            yajl_gen_array_open(hand);
            for(idx=0; idx<RARRAY_LEN(obj); idx++) {
                otherObj = rb_ary_entry(obj, idx);
                yajl_encode_part(hand, otherObj, io);
            }
            yajl_gen_array_close(hand);
            break;
        case T_NIL:
            yajl_gen_null(hand);
            break;
        case T_TRUE:
            yajl_gen_bool(hand, 1);
            break;
        case T_FALSE:
            yajl_gen_bool(hand, 0);
            break;
        case T_FIXNUM:
        case T_FLOAT:
        case T_BIGNUM:
            str = rb_funcall(obj, intern_to_s, 0);
            objLen = RSTRING_LEN(str);
            yajl_gen_number(hand, RSTRING_PTR(str), (unsigned int)objLen);
            break;
        default:
            str = rb_funcall(obj, intern_to_s, 0);
            objLen = RSTRING_LEN(str);
            yajl_gen_string(hand, (const unsigned char *)RSTRING_PTR(str), (unsigned int)objLen);
            break;
    }
}

void yajl_parser_wrapper_free(void * wrapper) {
    struct yajl_parser_wrapper * w = wrapper;
    yajl_free(w->parser);
    free(w);
}

void yajl_parser_wrapper_mark(void * wrapper) {
    struct yajl_parser_wrapper * w = wrapper;
    rb_gc_mark(w->builderStack);
    rb_gc_mark(w->parse_complete_callback);
}

// YAJL Callbacks
static int yajl_found_null(void * ctx) {
    yajl_set_static_value(ctx, Qnil);
    yajl_check_and_fire_callback(ctx);
    return 1;
}

static int yajl_found_boolean(void * ctx, int boolean) {
    yajl_set_static_value(ctx, boolean ? Qtrue : Qfalse);
    yajl_check_and_fire_callback(ctx);
    return 1;
}

static int yajl_found_number(void * ctx, const char * numberVal, unsigned int numberLen) {
    VALUE subString = rb_str_new(numberVal, numberLen);
    char * cSubString = RSTRING_PTR(subString);
    
    if (strstr(cSubString, ".") != NULL ||
        strstr(cSubString, "e") != NULL ||
        strstr(cSubString, "E") != NULL) {
            yajl_set_static_value(ctx, rb_Float(subString));
    } else {
        yajl_set_static_value(ctx, rb_Integer(subString));
    }
    yajl_check_and_fire_callback(ctx);
    return 1;
}

static int yajl_found_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    yajl_set_static_value(ctx, rb_str_new((const char *)stringVal, stringLen));
    yajl_check_and_fire_callback(ctx);
    return 1;
}

static int yajl_found_hash_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    yajl_set_static_value(ctx, rb_str_new((const char *)stringVal, stringLen));
    yajl_check_and_fire_callback(ctx);
    return 1;
}

static int yajl_found_start_hash(void * ctx) {
    struct yajl_parser_wrapper * wrapper;
    GetParser((VALUE)ctx, wrapper);
    wrapper->nestedHashLevel++;
    yajl_set_static_value(ctx, rb_hash_new());
    return 1;
}

static int yajl_found_end_hash(void * ctx) {
    struct yajl_parser_wrapper * wrapper;
    GetParser((VALUE)ctx, wrapper);
    wrapper->nestedHashLevel--;
    if (RARRAY_LEN(wrapper->builderStack) > 1) {
        rb_ary_pop(wrapper->builderStack);
    }
    yajl_check_and_fire_callback(ctx);
    return 1;
}

static int yajl_found_start_array(void * ctx) {
    struct yajl_parser_wrapper * wrapper;
    GetParser((VALUE)ctx, wrapper);
    wrapper->nestedArrayLevel++;
    yajl_set_static_value(ctx, rb_ary_new());
    return 1;
}

static int yajl_found_end_array(void * ctx) {
    struct yajl_parser_wrapper * wrapper;
    GetParser((VALUE)ctx, wrapper);
    wrapper->nestedArrayLevel--;
    if (RARRAY_LEN(wrapper->builderStack) > 1) {
        rb_ary_pop(wrapper->builderStack);
    }
    yajl_check_and_fire_callback(ctx);
    return 1;
}


// Ruby Interface

/*
 * Document-class: Yajl::Parser
 *
 * This class contains methods for parsing JSON directly from an IO object.
 * The only basic requirment currently is that the IO object respond to #read(len) and #eof?
 * The IO is parsed until a complete JSON object has been read and a ruby object will be returned.
 */
 
/*
 * Document-method: new
 *
 * call-seq: new([:allow_comments => false, :check_utf8 => false])
 *
 * :allow_comments will turn on/off the check for comments inside the JSON stream.
 *
 * :check_utf8 will validate UTF8 characters found in the JSON stream.
 */
static VALUE rb_yajl_parser_new(int argc, VALUE * argv, VALUE klass) {
    struct yajl_parser_wrapper * wrapper;
    yajl_parser_config cfg;
    VALUE opts, obj;
    int allowComments = 1, checkUTF8 = 1;
    
    // Scan off config vars
    if (rb_scan_args(argc, argv, "01", &opts) == 1) {
        Check_Type(opts, T_HASH);
        
        if (rb_hash_aref(opts, ID2SYM(sym_allow_comments)) == Qfalse) {
            allowComments = 0;
        }
        if (rb_hash_aref(opts, ID2SYM(sym_check_utf8)) == Qfalse) {
            checkUTF8 = 0;
        }
    }
    cfg = (yajl_parser_config){allowComments, checkUTF8};
    
    obj = Data_Make_Struct(klass, struct yajl_parser_wrapper, yajl_parser_wrapper_mark, yajl_parser_wrapper_free, wrapper);
    wrapper->parser = yajl_alloc(&callbacks, &cfg, NULL, (void *)obj);
    wrapper->nestedArrayLevel = 0;
    wrapper->nestedHashLevel = 0;
    wrapper->objectsFound = 0;
    wrapper->builderStack = rb_ary_new();
    wrapper->parse_complete_callback = Qnil;
    rb_obj_call_init(obj, 0, 0);
    return obj;
}

/*
 * Document-method: initialize
 *
 * call-seq: initialize([:allow_comments => false, :check_utf8 => false])
 *
 * :allow_comments will turn on/off the check for comments inside the JSON stream.
 *
 * :check_utf8 will validate UTF8 characters found in the JSON stream.
*/
static VALUE rb_yajl_parser_init(int argc, VALUE * argv, VALUE self) {
    return self;
}

/*
 * Document-method: parse
 *
 * call-seq:
 *  parse(io, buffer_size=8092)
 *  parse(io, buffer_size=8092) { |obj| ... }
 *
 * +io+ is the stream to parse JSON from
 *
 * +buffer_size+ is the size of chunk that will be parsed off the stream for each loop of the parsing process.
 * 8092 is a good balance between the different types of streams (off disk, off a socket, etc...), but this option
 * is here so the caller can better tune their parsing depending on the type of stream being passed.
 * A larger read buffer will perform better for files off disk, where as a smaller size may be more efficient for
 * reading off of a socket directly.
 *
 * If a block was passed, it's called when an object has been parsed off the stream. This is especially
 * usefull when parsing a stream of multiple JSON objects.
 *
 * NOTE: you can optionally assign the +on_parse_complete+ callback, and it will be called the same way the optional
 * block is for this method.
*/
static VALUE rb_yajl_parser_parse(int argc, VALUE * argv, VALUE self) {
    struct yajl_parser_wrapper * wrapper;
    yajl_status stat;
    VALUE parsed, rbufsize, io, blk;
    
    GetParser(self, wrapper);
    parsed = rb_str_new2("");
    
    // setup our parameters
    rb_scan_args(argc, argv, "11&", &io, &rbufsize, &blk);
    if (NIL_P(rbufsize)) {
        rbufsize = INT2FIX(READ_BUFSIZE);
    } else {
        Check_Type(rbufsize, T_FIXNUM);
    }
    if (!NIL_P(blk)) {
        rb_yajl_set_complete_cb(self, blk);
    }
    
    // now parse from the IO
    while (rb_funcall(io, intern_eof, 0) != Qtrue) {
        rb_funcall(io, intern_io_read, 2, rbufsize, parsed);
        
        stat = yajl_parse(wrapper->parser, (const unsigned char *)RSTRING_PTR(parsed), RSTRING_LEN(parsed));
        
        if (stat != yajl_status_ok && stat != yajl_status_insufficient_data) {
            unsigned char * str = yajl_get_error(wrapper->parser, 1, (const unsigned char *)RSTRING_PTR(parsed), RSTRING_LEN(parsed));
            rb_raise(cParseError, "%s", (const char *) str);
            yajl_free_error(wrapper->parser, str);
            break;
        }
    }
    
    // parse any remaining buffered data
    stat = yajl_parse_complete(wrapper->parser);
    
    if (wrapper->parse_complete_callback != Qnil) {
        yajl_check_and_fire_callback((void *)self);
        return Qnil;
    }

    return rb_ary_pop(wrapper->builderStack);
}

/*
 * Document-method: parse_chunk
 *
 * call-seq: parse_chunk(string_chunk)
 *
 * +string_chunk+ can be a partial or full JSON string to push on the parser.
 *
 * This method will throw an exception if the +on_parse_complete+ callback hasn't been assigned yet.
 * The +on_parse_complete+ callback assignment is required so the user can handle objects that have been
 * parsed off the stream as they're found.
 */
static VALUE rb_yajl_parser_parse_chunk(VALUE self, VALUE chunk) {
    struct yajl_parser_wrapper * wrapper;
    yajl_status stat;
    
    GetParser(self, wrapper);
    if (NIL_P(chunk)) {
        rb_raise(cParseError, "Can't parse a nil string.");
        return Qnil;
    }
    
    if (wrapper->parse_complete_callback != Qnil) {
        stat = yajl_parse(wrapper->parser, (const unsigned char *)RSTRING_PTR(chunk), RSTRING_LEN(chunk));
        if (stat != yajl_status_ok && stat != yajl_status_insufficient_data) {
            unsigned char * str = yajl_get_error(wrapper->parser, 1, (const unsigned char *)RSTRING_PTR(chunk), RSTRING_LEN(chunk));
            rb_raise(cParseError, "%s", (const char *) str);
            yajl_free_error(wrapper->parser, str);
        }
    } else {
        rb_raise(cParseError, "The on_parse_complete callback isn't setup, parsing useless.");
    }

    return Qnil;
}

/*
 * Document-method: on_parse_complete=
 *
 * call-seq: on_parse_complete = Proc.new { |obj| ... }
 *
 * This callback setter allows you to pass a Proc/lambda or any other object that response to #call.
 *
 * It will pass a single parameter, the ruby object built from the last parsed JSON object
 */
static VALUE rb_yajl_set_complete_cb(VALUE self, VALUE callback) {
    struct yajl_parser_wrapper * wrapper;
    GetParser(self, wrapper);
    wrapper->parse_complete_callback = callback;
    return Qnil;
}

/*
 * Document-class: Yajl::Encoder
 *
 * This class contains methods for encoding a Ruby object into JSON, streaming it's output into an IO object.
 * The IO object need only respond to #write(str)
 * The JSON stream created is written to the IO in chunks, as it's being created.
 */

/*
 * Document-method: new
 *
 * call-seq: new([:pretty => false, :indent => '  '])
 *
 * :pretty will enable/disable beautifying or "pretty priting" the output string.
 *
 * :indent is the character(s) used to indent the output string.
 */
static VALUE rb_yajl_encoder_new(int argc, VALUE * argv, VALUE klass) {
    yajl_gen_config cfg;
    yajl_gen encoder;
    VALUE opts, obj, indent;
    const char * indentString = "  ";
    int beautify = 0;
    
    // Scan off config vars
    if (rb_scan_args(argc, argv, "01", &opts) == 1) {
        Check_Type(opts, T_HASH);
        
        if (rb_hash_aref(opts, ID2SYM(sym_pretty)) == Qtrue) {
            beautify = 1;
            indent = rb_hash_aref(opts, ID2SYM(sym_indent));
            if (indent != Qnil) {
                Check_Type(indent, T_STRING);
                indentString = RSTRING_PTR(indent);
            }
        }
    }
    cfg = (yajl_gen_config){beautify, indentString};
    
    encoder = yajl_gen_alloc(&cfg, NULL);
    obj = Data_Wrap_Struct(klass, 0, yajl_gen_free, encoder);
    rb_obj_call_init(obj, 0, 0);
    return obj;
}

/*
 * Document-method: initialize
 *
 * call-seq: initialize([:pretty => false, :indent => '  '])
 *
 * :pretty will enable/disable beautifying or "pretty priting" the output string.
 *
 * :indent is the character(s) used to indent the output string.
 */
static VALUE rb_yajl_encoder_init(int argc, VALUE * argv, VALUE self) {
    return self;
}

/*
 * Document-method: encode
 *
 * call-seq: encode(obj, io)
 *
 * +obj+ is the Ruby object to encode to JSON
 *
 * +io+ is the IO stream to stream the encoded JSON string to.
 *
 * It should be noted that you can reuse an instance of this class to continue encoding multiple JSON
 * to the same stream. Just continue calling this method, passing it the same IO object with new/different
 * ruby objects to encode. This is how streaming is accomplished.
 */
static VALUE rb_yajl_encoder_encode(VALUE self, VALUE obj, VALUE io) {
    yajl_gen encoder;
    const unsigned char * buffer;
    unsigned int len;
    VALUE outBuff;
    
    GetEncoder(self, encoder);
    
    // begin encode process
    yajl_encode_part(encoder, obj, io);

    // just make sure we output the remaining buffer
    yajl_gen_get_buf(encoder, &buffer, &len);
    outBuff = rb_str_new((const char *)buffer, len);
    rb_io_write(io, outBuff);
    yajl_gen_clear(encoder);
    
    return Qnil;
}

// Ruby Extension initializer
void Init_yajl_ext() {
    mYajl = rb_define_module("Yajl");
    
    VALUE rb_cStandardError = rb_const_get(rb_cObject, rb_intern("StandardError"));
    cParseError = rb_define_class_under(mYajl, "ParseError", rb_cStandardError);
    
    cParser = rb_define_class_under(mYajl, "Parser", rb_cObject);
    rb_define_singleton_method(cParser, "new", rb_yajl_parser_new, -1);
    rb_define_method(cParser, "initialize", rb_yajl_parser_init, -1);
    rb_define_method(cParser, "parse", rb_yajl_parser_parse, -1);
    rb_define_method(cParser, "parse_chunk", rb_yajl_parser_parse_chunk, -1);
    rb_define_method(cParser, "<<", rb_yajl_parser_parse_chunk, 1);
    rb_define_method(cParser, "on_parse_complete=", rb_yajl_set_complete_cb, 1);
    
    cEncoder = rb_define_class_under(mYajl, "Encoder", rb_cObject);
    rb_define_singleton_method(cEncoder, "new", rb_yajl_encoder_new, -1);
    rb_define_method(cEncoder, "initialize", rb_yajl_encoder_init, -1);
    rb_define_method(cEncoder, "encode", rb_yajl_encoder_encode, 2);
    
    intern_io_read = rb_intern("read");
    intern_eof = rb_intern("eof?");
    intern_call = rb_intern("call");
    intern_keys = rb_intern("keys");
    intern_to_s = rb_intern("to_s");
    sym_allow_comments = rb_intern("allow_comments");
    sym_check_utf8 = rb_intern("check_utf8");
    sym_pretty = rb_intern("pretty");
    sym_indent = rb_intern("indent");
}