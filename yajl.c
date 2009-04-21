#include <yajl/yajl_parse.h>
#include <yajl/yajl_gen.h>
#include <ruby.h>

VALUE currentNest;

static int found_null(void * ctx) {
    VALUE val = Qnil;
    
    switch (TYPE(currentNest)) {
        case T_HASH:
            rb_hash_aset(currentNest, (VALUE)ctx, val);
            ctx = (void *)currentNest;
            break;
        case T_ARRAY:
            rb_ary_push(currentNest, val);
            ctx = (void *)currentNest;
            break;
        default:
            ctx = (void *)val;
            break;
    }
    return 1;
}

static int found_boolean(void * ctx, int boolean) {
    VALUE val = boolean ? Qtrue : Qfalse;
    
    switch (TYPE(currentNest)) {
        case T_HASH:
            rb_hash_aset(currentNest, (VALUE)ctx, val);
            ctx = currentNest;
            break;
        case T_ARRAY:
            rb_ary_push(currentNest, val);
            ctx = currentNest;
            break;
        default:
            ctx = val;
            break;
    }
    return 1;
}

static int found_integer(void * ctx, long integerVal) {
    VALUE val = LONG2FIX(integerVal);
    
    switch (TYPE(currentNest)) {
        case T_HASH:
            rb_hash_aset(currentNest, (VALUE)ctx, val);
            ctx = (void *)currentNest;
            break;
        case T_ARRAY:
            rb_ary_push(currentNest, val);
            ctx = (void *)currentNest;
            break;
        default:
            ctx = (void *)val;
            break;
    }
    return 1;
}

static int found_double(void * ctx, double doubleVal) {
    VALUE val = rb_float_new(doubleVal);
    
    switch (TYPE(currentNest)) {
        case T_HASH:
            rb_hash_aset(currentNest, (VALUE)ctx, val);
            ctx = (void *)currentNest;
            break;
        case T_ARRAY:
            rb_ary_push(currentNest, val);
            ctx = (void *)currentNest;
            break;
        default:
            ctx = (void *)val;
            break;
    }
    return 1;
}

static int found_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    VALUE val = rb_str_new(stringVal, stringLen);
    
    switch (TYPE(currentNest)) {
        case T_HASH:
            rb_hash_aset(currentNest, (VALUE)ctx, val);
            ctx = (void *)currentNest;
            break;
        case T_ARRAY:
            rb_ary_push(currentNest, val);
            ctx = (void *)currentNest;
            break;
        default:
            ctx = (void *)val;
            break;
    }
    return 1;
}

static int found_hash_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    VALUE str = rb_str_new(stringVal, stringLen);
    ctx = (void *)str;
    
    if (currentNest != Qnil) {
        rb_hash_aset(currentNest, str, Qnil);
        ctx = (void *)currentNest;
    }
    return 1;
}

static int found_start_hash(void * ctx) {
    currentNest = rb_hash_new();
    ctx = (void *)currentNest;
    return 1;
}

static int found_end_hash(void * ctx) {
    ctx = (void *)currentNest;
    currentNest = Qnil;
    return 1;
}

static int found_start_array(void * ctx) {
    currentNest = rb_ary_new();
    ctx = (void *)currentNest;
    return 1;
}

static int found_end_array(void * ctx) {
    ctx = (void *)currentNest;
    currentNest = Qnil;
    return 1;
}

static yajl_callbacks callbacks = {
    found_null,
    found_boolean,
    found_integer,
    found_double,
    NULL,
    found_string,
    found_start_hash,
    found_hash_key,
    found_end_hash,
    found_start_array,
    found_end_array
};

ID intern_io_read;

static VALUE t_parse(VALUE self, VALUE io) {
    yajl_handle hand;
    yajl_status stat;
    int bufferSize = 8192;
    yajl_parser_config cfg = {1, 1};
    intern_io_read = rb_intern("read");
    VALUE ctx = Qnil;
    
    // allocate our parser
    hand = yajl_alloc(&callbacks, &cfg, NULL, (void *)ctx);
    VALUE parsed = rb_str_new2("");
    VALUE rbufsize = INT2FIX(bufferSize);
    
    // now parse from the IO
    while (rb_io_eof(io) == Qfalse) {
        rb_funcall(io, intern_io_read, 2, rbufsize, parsed);
        
        stat = yajl_parse(hand, RSTRING_PTR(parsed), RSTRING_LEN(parsed));
        
        if (stat != yajl_status_ok && stat != yajl_status_insufficient_data) {
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