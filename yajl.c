#include <yajl/yajl_parse.h>
#include <yajl/yajl_gen.h>
#include <ruby.h>

static int found_null(void * ctx) {
    VALUE key = rb_ary_pop((VALUE)ctx);
    VALUE hash = rb_ary_pop((VALUE)ctx);
    switch (TYPE(key)) {
        case T_STRING:
            rb_hash_aset(hash, key, Qnil);
            break;
    }
    rb_ary_push((VALUE)ctx, hash);
    rb_ary_push((VALUE)ctx, key);
    return 1;
}

static int found_boolean(void * ctx, int boolean) {
    VALUE key = rb_ary_pop((VALUE)ctx);
    VALUE hash = rb_ary_pop((VALUE)ctx);
    switch (TYPE(key)) {
        case T_STRING:
            if (boolean) {
                rb_hash_aset(hash, key, Qtrue);
            } else {
                rb_hash_aset(hash, key, Qfalse);
            }
            break;
    }
    rb_ary_push((VALUE)ctx, hash);
    rb_ary_push((VALUE)ctx, key);
    return 1;
}

static int found_integer(void * ctx, long integerVal) {
    VALUE key = rb_ary_pop((VALUE)ctx);
    VALUE hash = rb_ary_pop((VALUE)ctx);
    switch (TYPE(key)) {
        case T_STRING:
            rb_hash_aset(hash, key, LONG2FIX(integerVal));
            break;
    }
    rb_ary_push((VALUE)ctx, hash);
    rb_ary_push((VALUE)ctx, key);
    return 1;
}

static int found_double(void * ctx, double doubleVal) {
    VALUE key = rb_ary_pop((VALUE)ctx);
    VALUE hash = rb_ary_pop((VALUE)ctx);
    switch (TYPE(key)) {
        case T_STRING:
            rb_hash_aset(hash, key, rb_float_new(doubleVal));
            break;
    }
    rb_ary_push((VALUE)ctx, hash);
    rb_ary_push((VALUE)ctx, key);
    return 1;
}

static int found_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    VALUE key = rb_ary_pop((VALUE)ctx);
    VALUE hash = rb_ary_pop((VALUE)ctx);
    switch (TYPE(key)) {
        case T_STRING:
            rb_hash_aset(hash, key, rb_str_new(stringVal, stringLen));
            break;
    }
    rb_ary_push((VALUE)ctx, hash);
    rb_ary_push((VALUE)ctx, key);
    return 1;
}

static int found_hash_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    VALUE last = rb_ary_pop((VALUE)ctx);
    VALUE str = rb_str_new(stringVal, stringLen);
    
    switch (TYPE(last)) {
        case T_HASH:
            rb_hash_aset(last, str, Qnil);
            rb_ary_push((VALUE)ctx, last);
            rb_ary_push((VALUE)ctx, str);
            break;
        default:
            // TODO: remove this
            // shouldn't get here...
            break;
    }
    return 1;
}

static int found_start_hash(void * ctx) {
    VALUE len, lastEntry, lastHash, newHash;
    
    len = RARRAY((VALUE)ctx)->len;
    newHash = rb_hash_new();
    
    if (len > 0) {
        lastEntry = rb_ary_pop((VALUE)ctx);
        switch (TYPE(lastEntry)) {
            case T_STRING:
                lastHash = rb_ary_pop((VALUE)ctx);
                rb_hash_aset(lastHash, lastEntry, newHash);
                rb_ary_push((VALUE)ctx, lastHash);
                rb_ary_push((VALUE)ctx, lastEntry);
                rb_ary_push((VALUE)ctx, newHash);
                break;
            case T_ARRAY:
                rb_ary_push(lastEntry, newHash);
                rb_ary_push((VALUE)ctx, lastEntry);
                rb_ary_push((VALUE)ctx, newHash);
                break;
        }
    } else {
        rb_ary_push((VALUE)ctx, newHash);
    }
    
    return 1;
}

static int found_end_hash(void * ctx) {
    VALUE len = RARRAY((VALUE)ctx)->len;
    
    if (len > 1) {
        rb_ary_pop((VALUE)ctx);
    }
    return 1;
}

static int found_start_array(void * ctx) {
    VALUE len, lastEntry, lastHash, lastArr, newArr;
    
    len = RARRAY((VALUE)ctx)->len;
    newArr = rb_ary_new();
    
    lastEntry = rb_ary_pop((VALUE)ctx);
    switch (TYPE(lastEntry)) {
        case T_STRING:
            lastHash = rb_ary_pop((VALUE)ctx);
            rb_hash_aset(lastHash, lastEntry, newArr);
            rb_ary_push((VALUE)ctx, lastHash);
            rb_ary_push((VALUE)ctx, lastEntry);
            rb_ary_push((VALUE)ctx, newArr);
            break;
        case T_ARRAY:
            rb_ary_push(lastEntry, newArr);
            rb_ary_push((VALUE)ctx, lastEntry);
            rb_ary_push((VALUE)ctx, newArr);
            break;
    }
    
    return 1;
}

static int found_end_array(void * ctx) {
    VALUE len = RARRAY((VALUE)ctx)->len;
    
    if (len > 1) {
        rb_ary_pop((VALUE)ctx);
    }
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
    VALUE ctx = rb_ary_new();
    intern_io_read = rb_intern("read");
    
    // allocate our parser
    hand = yajl_alloc(&callbacks, &cfg, NULL, (void *)ctx);
    VALUE parsed = rb_str_new2("");
    VALUE rbufsize = INT2FIX(bufferSize);
    
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
    return rb_ary_pop(ctx);
    // return ctx;
}

VALUE mYajl;
VALUE mNative;

void Init_yajl() {
    mYajl = rb_define_module("Yajl");
    mNative = rb_define_module_under(mYajl, "Native");
    rb_define_module_function(mNative, "parse", t_parse, 1);
}