#include <yajl/yajl_parse.h>
#include <yajl/yajl_gen.h>
#include <ruby.h>

static int found_null(void * ctx) {
    // Qnil
    return 1;
}

static int found_boolean(void * ctx, int boolean) {
    if (boolean) {
        // Qtrue
    } else {
        // Qfalse
    }
    return 1;
}

static int found_integer(void * ctx, long val) {
    VALUE i = INT2FIX(val);
    return 1;
}

static int found_double(void * ctx, double val) {
    VALUE f = rb_float_new(val);
    return 1;
}

static int found_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    VALUE s = rb_str_new(stringVal, stringLen);
    return 1;
}

static int found_map_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    rb_hash_aset((VALUE)ctx, rb_str_new(stringVal, stringLen), Qnil);
    return 1;
}

static int found_start_map(void * ctx) {
    if ((VALUE)ctx == Qnil) {
       ctx = (void *)rb_hash_new();
    } else {
        // TODO - nested hash
        // push context stack?
    }
    return 1;
}

static int found_end_map(void * ctx) {
    // TODO: pop off context stack?
    return 1;
}

static int found_start_array(void * ctx) {
    // rb_ary_new
    // push onto context stack?
    return 1;
}

static int found_end_array(void * ctx) {
    // pop off context stack?
    return 1;
}

static yajl_callbacks callbacks = {
    found_null,
    found_boolean,
    found_integer,
    found_double,
    NULL,
    found_string,
    found_start_map,
    found_map_key,
    found_end_map,
    found_start_array,
    found_end_array
};

ID intern_io_read;

static VALUE t_parse(VALUE self, VALUE io) {
    yajl_handle hand;
    yajl_status stat;
    int bufferSize = 8192;
    yajl_parser_config cfg = {1, 1};
    VALUE ctx = rb_hash_new();
    intern_io_read = rb_intern("read");
    
    // allocate our parser
    hand = yajl_alloc(&callbacks, &cfg, NULL, (void *)ctx);
    VALUE parsed = rb_str_new2("");
    VALUE rbufsize = INT2NUM(bufferSize);
    
    // now parse from the IO
    while (rb_io_eof(io) == Qfalse) {
        rb_funcall(io, intern_io_read, 2, rbufsize, parsed);
        stat = yajl_parse(hand, RSTRING_PTR(parsed), RSTRING_LEN(parsed));
        
        if (stat != yajl_status_ok &&
            stat != yajl_status_insufficient_data) {
            unsigned char * str = yajl_get_error(hand, 1, RSTRING_PTR(parsed), RSTRING_LEN(parsed));
            fprintf(stderr, (const char *) str);
            yajl_free_error(hand, str);
            break;
        }
    }
    
    // parse any remaining buffered data
    stat = yajl_parse_complete(hand);
    yajl_free(hand);
    return ctx;
}

VALUE mYajl;
VALUE mNative;

void Init_yajl() {
    mYajl = rb_define_module("Yajl");
    mNative = rb_define_module_under(mYajl, "Native");
    rb_define_module_function(mNative, "parse", t_parse, 1);
}