#include <yajl/yajl_parse.h>
#include <yajl/yajl_gen.h>
#include "ruby.h"

static int parse_null(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_null(g);
    return 1;
}

static int parse_boolean(void * ctx, int boolean) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_bool(g, boolean);
    return 1;
}

static int parse_number(void * ctx, const char * s, unsigned int l) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_number(g, s, l);
    return 1;
}

static int parse_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_string(g, stringVal, stringLen);
    return 1;
}

static int parse_map_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_string(g, stringVal, stringLen);
    return 1;
}

static int parse_start_map(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_map_open(g);
    return 1;
}

static int parse_end_map(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_map_close(g);
    return 1;
}

static int parse_start_array(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_array_open(g);
    return 1;
}

static int parse_end_array(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_array_close(g);
    return 1;
}

static yajl_callbacks callbacks = {
    parse_null,
    parse_boolean,
    NULL,
    NULL,
    parse_number,
    parse_string,
    parse_start_map,
    parse_map_key,
    parse_end_map,
    parse_start_array,
    parse_end_array
};

// ruby-specific awesomeness

static VALUE t_parse(VALUE io) {
    yajl_handle hand;
    yajl_status stat;
    size_t rd;
    int done = 0;
    int bufferSize = 65536;
    yajl_parser_config cfg = {1, 1};
    const char* emptyStr;
    VALUE ctx = rb_hash_new();
    VALUE streamData = rb_str_new(emptyStr, bufferSize);

    // allocate our parser
    hand = yajl_alloc(&callbacks, &cfg, NULL, (void *) &ctx);
    
    // parse from IO
    while (rb_funcall(io, rb_intern('read'), 2, bufferSize, streamData)) {
        stat = yajl_parse(hand, (unsigned char const *)RSTRING_PTR(streamData), RSTRING_LEN(streamData));
    }
    
    // parse any remaining buffered data
    stat = yajl_parse_complete(hand);
    
    yajl_free(hand);
    
    return ctx;
}

VALUE cYajl;

void Init_yajl() {
    cYajl = rb_define_class("Yajl", rb_cObject);
    rb_define_singleton_method(cYajl, "parse", t_parse, 1);
}