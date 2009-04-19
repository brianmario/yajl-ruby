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

static VALUE t_parse(VALUE self, VALUE io) {
    yajl_handle hand;
    yajl_status stat;
    static unsigned char fileData[65536];
    size_t rd;
    int done = 0;
    yajl_parser_config cfg = {1, 1};
    VALUE ctx = rb_hash_new();

    // allocate our parser
    hand = yajl_alloc(&callbacks, &cfg, NULL, (void *) ctx);
    
    while (!done) {
        // parse a chunk from our IO
        
        // if (read from IO was empty or EOF) {
        //    done = 1;
        // }
        done = 1;
    }
}

VALUE cYajl;

void Init_Yajl() {
    cYajl = rb_define_class("Yajl", rb_cObject);
    rb_define_singleton_method(cYajl, "parse", t_parse, 2);
}