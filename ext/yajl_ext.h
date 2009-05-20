#include "api/yajl_parse.h"
#include "api/yajl_gen.h"
#include <ruby.h>

#define READ_BUFSIZE 4096

static VALUE cParseError, mYajl, mStream, mChunked;
static ID intern_io_read, intern_eof, intern_respond_to, intern_call, intern_keys, intern_to_s;
static int readBufferSize = READ_BUFSIZE;
static yajl_parser_config cfg = {1, 1};

yajl_handle streamParser, chunkedParser;
VALUE context = Qnil;
VALUE parse_complete_callback = Qnil;
static int needArrayVal = 0;

void check_and_fire_callback(void * ctx);
void set_static_value(void * ctx, VALUE val);

static int found_null(void * ctx);
static int found_boolean(void * ctx, int boolean);
static int found_number(void * ctx, const char * numberVal, unsigned int numberLen);
static int found_string(void * ctx, const unsigned char * stringVal, unsigned int stringLen);
static int found_hash_key(void * ctx, const unsigned char * stringVal, unsigned int stringLen);
static int found_start_hash(void * ctx);
static int found_end_hash(void * ctx);
static int found_start_array(void * ctx);
static int found_end_array(void * ctx);

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

static VALUE t_setParseComplete(VALUE self, VALUE callback);
static VALUE t_parseSome(VALUE self, VALUE string);
static VALUE t_parse(VALUE self, VALUE io);
static VALUE t_encode(VALUE self, VALUE obj, VALUE io);
