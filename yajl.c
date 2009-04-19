#include <yajl/yajl_parse.h>
#include <yajl/yajl_gen.h>
#include "ruby.h"
#include "rubyio.h"

static int parse_null(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_null(g);
    // rb_eval_string("puts 'Found a null'");
    return 1;
}

static int parse_boolean(void * ctx, int boolean) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_bool(g, boolean);
    // rb_eval_string("puts 'Found a boolean'");
    return 1;
}

static int parse_number(void * ctx, const char * s, unsigned int l) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_number(g, s, l);
    // rb_eval_string("puts 'Found a number'");
    return 1;
}

static int parse_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_string(g, stringVal, stringLen);
    // rb_eval_string("puts 'Found a string'");
    return 1;
}

static int parse_map_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_string(g, stringVal, stringLen);
    // rb_eval_string("puts 'Found a Hash key'");
    return 1;
}

static int parse_start_map(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_map_open(g);
    // rb_eval_string("puts 'Found the beginning of a Hash'");
    return 1;
}

static int parse_end_map(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_map_close(g);
    // rb_eval_string("puts 'Found the end of a Hash'");
    return 1;
}

static int parse_start_array(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_array_open(g);
    // rb_eval_string("puts 'Found the beginning of an Array'");
    return 1;
}

static int parse_end_array(void * ctx) {
    // yajl_gen g = (yajl_gen) ctx;
    // yajl_gen_array_close(g);
    // rb_eval_string("puts 'Found the end of an Array'");
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
    // int bufferSize = 65536;
    yajl_parser_config cfg = {1, 1};
    VALUE ctx = rb_hash_new();
    
    // allocate our parser
    hand = yajl_alloc(&callbacks, &cfg, NULL, (void *) &ctx);
    // parse from IO
    while (rb_io_eof(io) != Qtrue) {
        VALUE parsed = rb_io_gets(io);
        stat = yajl_parse(hand, (unsigned char const *)RSTRING_PTR(parsed), RSTRING_LEN(parsed));
        
        if (stat != yajl_status_ok &&
            stat != yajl_status_insufficient_data)
        {
            unsigned char * str = yajl_get_error(hand, 1, (unsigned char const *)RSTRING_PTR(parsed), RSTRING_LEN(parsed));
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

VALUE cYajl;
VALUE cNative;

void Init_yajl() {
    cYajl = rb_define_module("Yajl");
    cNative = rb_define_module_under(cYajl, "Native");
    rb_define_module_function(cNative, "parse", t_parse, 1);
}