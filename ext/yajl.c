#include <yajl/yajl_parse.h>
#include <yajl/yajl_gen.h>
#include <ruby.h>

#define READ_BUFSIZE 4096

static VALUE cParseError;
static ID intern_io_read, intern_eof, intern_respond_to;
static int readBufferSize = READ_BUFSIZE;

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
    return 1;
}

static int found_boolean(void * ctx, int boolean) {
    set_static_value(ctx, boolean ? Qtrue : Qfalse);
    return 1;
}

static int found_number(void * ctx, const char * numberVal, unsigned int numberLen) {
    if (strstr(numberVal, ".") != NULL
        || strstr(numberVal, "e") != NULL
        || strstr(numberVal, "E") != NULL) {
        set_static_value(ctx, rb_Float(rb_str_new(numberVal, numberLen)));
    } else {
        set_static_value(ctx, rb_Integer(rb_str_new(numberVal, numberLen)));
    }
    
    return 1;
}

static int found_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    set_static_value(ctx, rb_str_new((char *)stringVal, stringLen));
    return 1;
}

static int found_hash_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    set_static_value(ctx, rb_str_new((char *)stringVal, stringLen));
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
    return 1;
}

static yajl_callbacks callbacks = {
    found_null,
    found_boolean,
    NULL,
    NULL,
    found_number,
    found_string,
    found_start_hash,
    found_hash_key,
    found_end_hash,
    found_start_array,
    found_end_array
};

static yajl_parser_config cfg = {1, 1};

static VALUE t_parse(VALUE self, VALUE io) {
    yajl_handle hand;
    yajl_status stat;
    
    VALUE ctx = rb_ary_new();
    
    // allocate our parser
    hand = yajl_alloc(&callbacks, &cfg, NULL, (void *)ctx);
    VALUE parsed = rb_str_new("", readBufferSize);
    VALUE rbufsize = INT2FIX(readBufferSize);
    
    // now parse from the IO
    while (rb_funcall(io, intern_eof, 0) == Qfalse) {
        parsed = rb_funcall(io, intern_io_read, 1, rbufsize);
        
        stat = yajl_parse(hand, (const unsigned char *)RSTRING_PTR(parsed), RSTRING_LEN(parsed));
        
        if (stat != yajl_status_ok && stat != yajl_status_insufficient_data) {
            unsigned char * str = yajl_get_error(hand, 1, (const unsigned char *)RSTRING_PTR(parsed), RSTRING_LEN(parsed));
            rb_raise(cParseError, "%s", (const char *) str);
            yajl_free_error(hand, str);
            break;
        }
    }
    
    // parse any remaining buffered data
    stat = yajl_parse_complete(hand);
    yajl_free(hand);

    return rb_ary_pop(ctx);
}

static VALUE mYajl, mNative;

void Init_yajl() {
    mYajl = rb_define_module("Yajl");
    mNative = rb_define_module_under(mYajl, "Native");
    rb_define_module_function(mNative, "parse", t_parse, 1);
    VALUE rb_cStandardError = rb_const_get(rb_cObject, rb_intern("StandardError"));
    cParseError = rb_define_class_under(mYajl, "ParseError", rb_cStandardError);
    
    intern_io_read = rb_intern("read");
    intern_eof = rb_intern("eof?");
    intern_respond_to = rb_intern("respond_to?");
}