#include "api/yajl_parse.h"
#include "api/yajl_gen.h"
#include <ruby.h>

#define READ_BUFSIZE 8092
#define WRITE_BUFSIZE 8092

static VALUE cParseError, cEncodeError, mYajl, cParser, cEncoder;
static ID intern_io_read, intern_eof, intern_call, intern_keys, intern_to_s, intern_to_json, intern_has_key,
          sym_allow_comments, sym_check_utf8, sym_pretty, sym_indent, sym_terminator, sym_symbolize_keys;

#define GetParser(obj, sval) (sval = (struct yajl_parser_wrapper*)DATA_PTR(obj));
#define GetEncoder(obj, sval) (sval = (struct yajl_encoder_wrapper*)DATA_PTR(obj));

inline void yajl_check_and_fire_callback(void * ctx);
inline void yajl_set_static_value(void * ctx, VALUE val);
void yajl_encode_part(void * wrapper, VALUE obj, VALUE io);
void yajl_parse_chunk(const unsigned char * chunk, unsigned int len, yajl_handle parser);

static int yajl_found_null(void * ctx);
static int yajl_found_boolean(void * ctx, int boolean);
static int yajl_found_number(void * ctx, const char * numberVal, unsigned int numberLen);
static int yajl_found_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen);
static int yajl_found_hash_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen);
static int yajl_found_start_hash(void * ctx);
static int yajl_found_end_hash(void * ctx);
static int yajl_found_start_array(void * ctx);
static int yajl_found_end_array(void * ctx);

static yajl_callbacks callbacks = {
    yajl_found_null,
    yajl_found_boolean,
    NULL,
    NULL,
    yajl_found_number,
    yajl_found_string,
    yajl_found_start_hash,
    yajl_found_hash_key,
    yajl_found_end_hash,
    yajl_found_start_array,
    yajl_found_end_array
};

struct yajl_parser_wrapper {
    VALUE builderStack;
    VALUE parse_complete_callback;
    int nestedArrayLevel;
    int nestedHashLevel;
    int objectsFound;
    int symbolizeKeys;
    yajl_handle parser;
};

struct yajl_encoder_wrapper {
    VALUE on_progress_callback;
    VALUE terminator;
    yajl_gen encoder;
};

static VALUE rb_yajl_parser_new(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_parser_init(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_parser_parse(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_parser_parse_chunk(VALUE self, VALUE chunk);
static VALUE rb_yajl_parser_set_complete_cb(VALUE self, VALUE callback);
static void yajl_parser_wrapper_free(void * wrapper);
static void yajl_parser_wrapper_mark(void * wrapper);

static VALUE rb_yajl_encoder_new(int argc, VALUE * argv, VALUE klass);
static VALUE rb_yajl_encoder_init(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_encoder_encode(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_encoder_set_progress_cb(VALUE self, VALUE callback);
static void yajl_encoder_wrapper_free(void * wrapper);
static void yajl_encoder_wrapper_mark(void * wrapper);

static VALUE rb_yajl_json_ext_hash_to_json(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_json_ext_array_to_json(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_json_ext_fixnum_to_json(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_json_ext_float_to_json(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_json_ext_string_to_json(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_json_ext_true_to_json(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_json_ext_false_to_json(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_json_ext_nil_to_json(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_encoder_enable_json_gem_ext(VALUE klass);