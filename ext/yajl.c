#include "yajl.h"

void check_and_fire_callback(void * ctx) {
    yajl_status stat;
    
    if (RARRAY_LEN((VALUE)ctx) == 1 && parse_complete_callback != Qnil) {
        // parse any remaining buffered data
        stat = yajl_parse_complete(chunkedParser);
        
        rb_funcall(parse_complete_callback, intern_call, 1, rb_ary_pop((VALUE)ctx));
    }
}

void set_static_value(void * ctx, VALUE val) {
    VALUE len = RARRAY_LEN((VALUE)ctx);
    
    if (len > 0) {
        VALUE lastEntry = rb_ary_entry((VALUE)ctx, len-1);
        VALUE hash;
        switch (TYPE(lastEntry)) {
            case T_ARRAY:
                rb_ary_push(lastEntry, val);
                if (TYPE(val) == T_HASH || TYPE(val) == T_ARRAY) {
                    rb_ary_push((VALUE)ctx, val);
                }
                break;
            case T_HASH:
                rb_hash_aset(lastEntry, val, Qnil);
                rb_ary_push((VALUE)ctx, val);
                break;
            case T_STRING:
                hash = rb_ary_entry((VALUE)ctx, len-2);
                if (TYPE(hash) == T_HASH) {
                    rb_hash_aset(hash, lastEntry, val);
                    rb_ary_pop((VALUE)ctx);
                    if (TYPE(val) == T_HASH || TYPE(val) == T_ARRAY) {
                        rb_ary_push((VALUE)ctx, val);
                    }
                }
                break;
        }
    } else {
        rb_ary_push((VALUE)ctx, val);
    }
}

static int found_null(void * ctx) {
    set_static_value(ctx, Qnil);
    check_and_fire_callback(ctx);
    return 1;
}

static int found_boolean(void * ctx, int boolean) {
    set_static_value(ctx, boolean ? Qtrue : Qfalse);
    check_and_fire_callback(ctx);
    return 1;
}

static int found_number(void * ctx, const char * numberVal, unsigned int numberLen) {
    if (strstr(numberVal, ".") != NULL || strstr(numberVal, "e") != NULL || strstr(numberVal, "E") != NULL) {
        set_static_value(ctx, rb_Float(rb_str_new(numberVal, numberLen)));
    } else {
        set_static_value(ctx, rb_Integer(rb_str_new(numberVal, numberLen)));
    }
    check_and_fire_callback(ctx);
    return 1;
}

static int found_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    set_static_value(ctx, rb_str_new((const char *)stringVal, stringLen));
    check_and_fire_callback(ctx);
    return 1;
}

static int found_hash_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    set_static_value(ctx, rb_str_new((const char *)stringVal, stringLen));
    return 1;
}

static int found_start_hash(void * ctx) {
    set_static_value(ctx, rb_hash_new());
    return 1;
}

static int found_end_hash(void * ctx) {
    if (RARRAY_LEN((VALUE)ctx) > 1) {
        rb_ary_pop((VALUE)ctx);
    }
    check_and_fire_callback(ctx);
    return 1;
}

static int found_start_array(void * ctx) {
    set_static_value(ctx, rb_ary_new());
    return 1;
}

static int found_end_array(void * ctx) {
    if (RARRAY_LEN((VALUE)ctx) > 1) {
        rb_ary_pop((VALUE)ctx);
    }
    check_and_fire_callback(ctx);
    return 1;
}

static VALUE t_setParseComplete(VALUE self, VALUE callback) {
    parse_complete_callback = callback;
    return Qnil;
}

static VALUE t_parseSome(VALUE self, VALUE string) {
    yajl_status stat;
    
    if (string == Qnil) {
        rb_raise(cParseError, "%s", "Can't parse a nil string.");
        return Qnil;
    }
    
    if (parse_complete_callback != Qnil) {
        if (context == Qnil) {
            context = rb_ary_new();
        }
        if (chunkedParser == NULL) {
            // allocate our parser
            chunkedParser = yajl_alloc(&callbacks, &cfg, NULL, (void *)context);
        }
        
        stat = yajl_parse(chunkedParser, (const unsigned char *)RSTRING_PTR(string), RSTRING_LEN(string));
        if (stat != yajl_status_ok && stat != yajl_status_insufficient_data) {
            unsigned char * str = yajl_get_error(chunkedParser, 1, (const unsigned char *)RSTRING_PTR(string), RSTRING_LEN(string));
            rb_raise(cParseError, "%s", (const char *) str);
            yajl_free_error(chunkedParser, str);
        }
    } else {
        rb_raise(cParseError, "%s", "The on_parse_complete callback isn't setup, parsing useless.");
    }
    
    if (RARRAY_LEN(context) == 0) {
        yajl_free(chunkedParser);
    }
    
    return Qnil;
}

static VALUE t_parse(VALUE self, VALUE io) {
    yajl_status stat;
    context = rb_ary_new();
    
    // allocate our parser
    streamParser = yajl_alloc(&callbacks, &cfg, NULL, (void *)context);
    
    VALUE parsed = rb_str_new("", readBufferSize);
    VALUE rbufsize = INT2FIX(readBufferSize);
    
    // now parse from the IO
    while (rb_funcall(io, intern_eof, 0) != Qtrue) {
        rb_funcall(io, intern_io_read, 2, rbufsize, parsed);
        
        stat = yajl_parse(streamParser, (const unsigned char *)RSTRING_PTR(parsed), RSTRING_LEN(parsed));
        
        if (stat != yajl_status_ok && stat != yajl_status_insufficient_data) {
            unsigned char * str = yajl_get_error(streamParser, 1, (const unsigned char *)RSTRING_PTR(parsed), RSTRING_LEN(parsed));
            rb_raise(cParseError, "%s", (const char *) str);
            yajl_free_error(streamParser, str);
            break;
        }
    }
    
    // parse any remaining buffered data
    stat = yajl_parse_complete(streamParser);
    yajl_free(streamParser);
    
    if (parse_complete_callback != Qnil) {
        check_and_fire_callback((void *)context);
        return Qnil;
    }

    return rb_ary_pop(context);
}

void Init_yajl() {
    mYajl = rb_define_module("Yajl");
    
    mStream = rb_define_module_under(mYajl, "Stream");
    rb_define_module_function(mStream, "parse", t_parse, 1);
    
    mChunked = rb_define_module_under(mYajl, "Chunked");
    rb_define_module_function(mChunked, "parse_some", t_parseSome, 1);
    rb_define_module_function(mChunked, "<<", t_parseSome, 1);
    rb_define_module_function(mChunked, "on_parse_complete=", t_setParseComplete, 1);
    
    VALUE rb_cStandardError = rb_const_get(rb_cObject, rb_intern("StandardError"));
    cParseError = rb_define_class_under(mYajl, "ParseError", rb_cStandardError);
    
    intern_io_read = rb_intern("read");
    intern_eof = rb_intern("eof?");
    intern_respond_to = rb_intern("respond_to?");
    intern_call = rb_intern("call");
}