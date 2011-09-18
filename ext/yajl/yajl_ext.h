#include "api/yajl_parse.h"
#include "common.h"

#define READ_BUFSIZE 8192

static VALUE cParseError, cParser;
static ID intern_io_read, intern_to_sym, intern_as_json;
static ID sym_allow_comments, sym_check_utf8, sym_symbolize_keys;

#define GetParser(obj, sval) (sval = (yajl_parser_wrapper*)DATA_PTR(obj));

inline void yajl_check_and_fire_callback(void * ctx);
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

typedef struct {
    VALUE builderStack;
    VALUE parse_complete_callback;
    int nestedArrayLevel;
    int nestedHashLevel;
    int objectsFound;
    int symbolizeKeys;
    yajl_handle parser;
} yajl_parser_wrapper;

static VALUE rb_yajl_parser_new(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_parser_init(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_parser_parse(int argc, VALUE * argv, VALUE self);
static VALUE rb_yajl_parser_parse_chunk(VALUE self, VALUE chunk);
static VALUE rb_yajl_parser_set_complete_cb(VALUE self, VALUE callback);
static void yajl_parser_wrapper_free(void * wrapper);
static void yajl_parser_wrapper_mark(void * wrapper);

void Init_yajl();