#include "common.h"
#include "yajl_parse.h"

#define READ_BUFSIZE 8192
#define GetParser(obj, sval) (sval = (yajl_parser_wrapper*)DATA_PTR(obj));

static VALUE cParseError, cParser;
static ID intern_io_read;
static ID sym_allow_comments, sym_check_utf8, sym_symbolize_keys;
extern ID intern_call;
extern VALUE mYajl;

typedef struct {
	VALUE builderStack;
	VALUE parse_complete_callback;
	int nestedArrayLevel;
	int nestedHashLevel;
	int objectsFound;
	int symbolizeKeys;
	yajl_handle parser;
} yajl_parser_wrapper;

inline void yajl_check_and_fire_callback(void * ctx) {
	yajl_parser_wrapper * wrapper;
	GetParser((VALUE)ctx, wrapper);

		/* No need to do any of this if the callback isn't even setup */
	if (wrapper->parse_complete_callback != Qnil) {
		int len = RARRAY_LEN(wrapper->builderStack);
		if (len == 1 && wrapper->nestedArrayLevel == 0 && wrapper->nestedHashLevel == 0) {
			rb_funcall(wrapper->parse_complete_callback, intern_call, 1, rb_ary_pop(wrapper->builderStack));
		}
	} else {
		int len = RARRAY_LEN(wrapper->builderStack);
		if (len == 1 && wrapper->nestedArrayLevel == 0 && wrapper->nestedHashLevel == 0) {
			wrapper->objectsFound++;
			if (wrapper->objectsFound > 1) {
				rb_raise(cParseError, "%s", "Found multiple JSON objects in the stream but no block or the on_parse_complete callback was assigned to handle them.");
			}
		}
	}
}
inline void yajl_set_static_value(void * ctx, VALUE val) {
	yajl_parser_wrapper * wrapper;
	VALUE lastEntry, hash;
	int len;

	GetParser((VALUE)ctx, wrapper);

	len = RARRAY_LEN(wrapper->builderStack);
	if (len > 0) {
		lastEntry = rb_ary_entry(wrapper->builderStack, len-1);
		switch (TYPE(lastEntry)) {
			case T_ARRAY:
			rb_ary_push(lastEntry, val);
			if (TYPE(val) == T_HASH || TYPE(val) == T_ARRAY) {
				rb_ary_push(wrapper->builderStack, val);
			}
			break;
			case T_HASH:
			rb_hash_aset(lastEntry, val, Qnil);
			rb_ary_push(wrapper->builderStack, val);
			break;
			case T_STRING:
			case T_SYMBOL:
			hash = rb_ary_entry(wrapper->builderStack, len-2);
			if (TYPE(hash) == T_HASH) {
				rb_hash_aset(hash, lastEntry, val);
				rb_ary_pop(wrapper->builderStack);
				if (TYPE(val) == T_HASH || TYPE(val) == T_ARRAY) {
					rb_ary_push(wrapper->builderStack, val);
				}
			}
			break;
		}
	} else {
		rb_ary_push(wrapper->builderStack, val);
	}
}
static void yajl_parse_chunk(const unsigned char * chunk, size_t len, yajl_handle parser) {
	yajl_status stat;

	stat = yajl_parse(parser, chunk, len);

	if (stat != yajl_status_ok) {
		unsigned char * str = yajl_get_error(parser, 1, chunk, len);
		VALUE errobj = rb_exc_new2(cParseError, (const char*) str);
		yajl_free_error(parser, str);
		rb_exc_raise(errobj);
	}
}

static int yajl_found_null(void * ctx) {
	yajl_set_static_value(ctx, Qnil);
	yajl_check_and_fire_callback(ctx);
	return 1;
}
static int yajl_found_boolean(void * ctx, int boolean) {
	yajl_set_static_value(ctx, boolean ? Qtrue : Qfalse);
	yajl_check_and_fire_callback(ctx);
	return 1;
}
static int yajl_found_number(void * ctx, const char * numberVal, size_t numberLen) {
	char buf[numberLen+1];
	buf[numberLen] = 0;
	memcpy(buf, numberVal, numberLen);

	if (memchr(buf, '.', numberLen) ||
		memchr(buf, 'e', numberLen) ||
	memchr(buf, 'E', numberLen)) {
		yajl_set_static_value(ctx, rb_float_new(strtod(buf, NULL)));
	} else {
		yajl_set_static_value(ctx, rb_cstr2inum(buf, 10));
	}
	return 1;
}
static int yajl_found_string(void * ctx, const unsigned char * stringVal, size_t stringLen) {
	VALUE str = rb_str_new((const char *)stringVal, stringLen);
#ifdef HAVE_RUBY_ENCODING_H
	rb_encoding *default_internal_enc = rb_default_internal_encoding();
	rb_enc_associate(str, rb_utf8_encoding());
	if (default_internal_enc) {
		str = rb_str_export_to_enc(str, default_internal_enc);
	}
#endif
	yajl_set_static_value(ctx, str);
	yajl_check_and_fire_callback(ctx);
	return 1;
}
static int yajl_found_hash_key(void * ctx, const unsigned char * stringVal, size_t stringLen) {
	yajl_parser_wrapper * wrapper;
	VALUE keyStr;
#ifdef HAVE_RUBY_ENCODING_H
	rb_encoding *default_internal_enc;
#endif
	GetParser((VALUE)ctx, wrapper);
#ifdef HAVE_RUBY_ENCODING_H
	default_internal_enc = rb_default_internal_encoding();
#endif

	if (wrapper->symbolizeKeys) {
		char buf[stringLen+1];
		memcpy(buf, stringVal, stringLen);
		buf[stringLen] = 0;
		VALUE stringEncoded = rb_str_new2(buf);
#ifdef HAVE_RUBY_ENCODING_H
		rb_enc_associate(stringEncoded, rb_utf8_encoding());
#endif

		yajl_set_static_value(ctx, ID2SYM(rb_to_id(stringEncoded)));
	} else {
		keyStr = rb_str_new((const char *)stringVal, stringLen);
#ifdef HAVE_RUBY_ENCODING_H
		rb_enc_associate(keyStr, rb_utf8_encoding());
		if (default_internal_enc) {
			keyStr = rb_str_export_to_enc(keyStr, default_internal_enc);
		}
#endif
		yajl_set_static_value(ctx, keyStr);
	}
	yajl_check_and_fire_callback(ctx);
	return 1;
}
static int yajl_found_start_hash(void * ctx) {
	yajl_parser_wrapper * wrapper;
	GetParser((VALUE)ctx, wrapper);
	wrapper->nestedHashLevel++;
	yajl_set_static_value(ctx, rb_hash_new());
	return 1;
}
static int yajl_found_end_hash(void * ctx) {
	yajl_parser_wrapper * wrapper;
	GetParser((VALUE)ctx, wrapper);
	wrapper->nestedHashLevel--;
	if (RARRAY_LEN(wrapper->builderStack) > 1) {
		rb_ary_pop(wrapper->builderStack);
	}
	yajl_check_and_fire_callback(ctx);
	return 1;
}
static int yajl_found_start_array(void * ctx) {
	yajl_parser_wrapper * wrapper;
	GetParser((VALUE)ctx, wrapper);
	wrapper->nestedArrayLevel++;
	yajl_set_static_value(ctx, rb_ary_new());
	return 1;
}
static int yajl_found_end_array(void * ctx) {
	yajl_parser_wrapper * wrapper;
	GetParser((VALUE)ctx, wrapper);
	wrapper->nestedArrayLevel--;
	if (RARRAY_LEN(wrapper->builderStack) > 1) {
		rb_ary_pop(wrapper->builderStack);
	}
	yajl_check_and_fire_callback(ctx);
	return 1;
}
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

static void yajl_parser_wrapper_free(void *wrapper) {
	yajl_parser_wrapper *w = wrapper;
	if (w) {
		yajl_free(w->parser);
		free(w);
	}
}
static void yajl_parser_wrapper_mark(void *wrapper) {
	yajl_parser_wrapper *w = wrapper;
	if (w) {
		rb_gc_mark(w->builderStack);
		rb_gc_mark(w->parse_complete_callback);
	}
}
static VALUE allocate(VALUE klass) {
	yajl_parser_wrapper *wrapper;
	VALUE obj;

	wrapper = malloc(sizeof(yajl_parser_wrapper));

	obj = Data_Wrap_Struct(klass, yajl_parser_wrapper_mark, yajl_parser_wrapper_free, wrapper);

	wrapper->parser = yajl_alloc(&callbacks, NULL, (void *)obj);

	return obj;
}

/*
* Document-class: Yajl::Parser
*
* This class contains methods for parsing JSON directly from an IO object.
* The only basic requirment currently is that the IO object respond to #read(len) and #eof?
* The IO is parsed until a complete JSON object has been read and a ruby object will be returned.
*/
/*
* Document-method: initialize
*
* call-seq: new([:symbolize_keys => true, [:allow_comments => false[, :check_utf8 => false]]])
*
* :symbolize_keys will turn hash keys into Ruby symbols, defaults to false.
*
* :allow_comments will turn on/off the check for comments inside the JSON stream, defaults to true.
*
* :check_utf8 will validate UTF-8 characters found in the JSON stream, defaults to true.
*/
static VALUE rb_yajl_parser_init(int argc, VALUE * argv, VALUE self) {
	yajl_parser_wrapper * wrapper;
	VALUE opts;
	int allowComments = 1, check_utf8 = 1, symbolizeKeys = 0;

	GetParser(self, wrapper);

	/* Scan off config vars */
	if (rb_scan_args(argc, argv, "01", &opts) == 1) {
		Check_Type(opts, T_HASH);

		if (rb_hash_aref(opts, sym_allow_comments) == Qfalse) {
			allowComments = 0;
		}
		if (rb_hash_aref(opts, sym_check_utf8) == Qfalse) {
			check_utf8 = 0;
		}
		if (rb_hash_aref(opts, sym_symbolize_keys) == Qtrue) {
			symbolizeKeys = 1;
		}
	}

	yajl_config(wrapper->parser, yajl_allow_comments, allowComments);
	yajl_config(wrapper->parser, yajl_dont_validate_strings, !check_utf8);
	yajl_config(wrapper->parser, yajl_allow_trailing_garbage, 1);
	yajl_config(wrapper->parser, yajl_allow_multiple_values, 1);

	wrapper->nestedArrayLevel = 0;
	wrapper->nestedHashLevel = 0;
	wrapper->objectsFound = 0;
	wrapper->symbolizeKeys = symbolizeKeys;
	wrapper->builderStack = rb_ary_new();
	wrapper->parse_complete_callback = Qnil;

	return self;
}
/*
* Document-method: on_parse_complete=
*
* call-seq: on_parse_complete = Proc.new { |obj| ... }
*
* This callback setter allows you to pass a Proc/lambda or any other object that responds to #call.
*
* It will pass a single parameter, the ruby object built from the last parsed JSON object
*/
static VALUE rb_yajl_parser_set_complete_cb(VALUE self, VALUE callback) {
	yajl_parser_wrapper * wrapper;
	GetParser(self, wrapper);
	wrapper->parse_complete_callback = callback;
	return Qnil;
}

/*
* Document-method: parse
*
* call-seq:
*  parse(input, buffer_size=8092)
*  parse(input, buffer_size=8092) { |obj| ... }
*
* +input+ can either be a string or an IO to parse JSON from
*
* +buffer_size+ is the size of chunk that will be parsed off the input (if it's an IO) for each loop of the parsing process.
* 8092 is a good balance between the different types of streams (off disk, off a socket, etc...), but this option
* is here so the caller can better tune their parsing depending on the type of stream being passed.
* A larger read buffer will perform better for files off disk, where as a smaller size may be more efficient for
* reading off of a socket directly.
*
* If a block was passed, it's called when an object has been parsed off the stream. This is especially
* usefull when parsing a stream of multiple JSON objects.
*
* NOTE: you can optionally assign the +on_parse_complete+ callback, and it will be called the same way the optional
* block is for this method.
*/
static VALUE rb_yajl_parser_parse(int argc, VALUE * argv, VALUE self) {
	yajl_status stat;
	yajl_parser_wrapper * wrapper;
	VALUE rbufsize, input, blk;
	size_t len;
	const char * cptr;

	GetParser(self, wrapper);

		/* setup our parameters */
	rb_scan_args(argc, argv, "11&", &input, &rbufsize, &blk);
	if (NIL_P(rbufsize)) {
		rbufsize = INT2FIX(READ_BUFSIZE);
	} else {
		Check_Type(rbufsize, T_FIXNUM);
	}
	if (!NIL_P(blk)) {
		rb_yajl_parser_set_complete_cb(self, blk);
	}

	if (TYPE(input) == T_STRING) {
		cptr = RSTRING_PTR(input);
		len = RSTRING_LEN(input);
		yajl_parse_chunk((const unsigned char*)cptr, len, wrapper->parser);
	} else if (rb_respond_to(input, intern_io_read)) {
		VALUE parsed = rb_str_new(0, FIX2LONG(rbufsize));
		while (rb_funcall(input, intern_io_read, 2, rbufsize, parsed) != Qnil) {
			cptr = RSTRING_PTR(parsed);
			len = RSTRING_LEN(parsed);
			yajl_parse_chunk((const unsigned char*)cptr, len, wrapper->parser);
		}
	} else {
		rb_raise(cParseError, "input must be a string or IO");
	}

		/* parse any remaining buffered data */
	stat = yajl_complete_parse(wrapper->parser);

	if (wrapper->parse_complete_callback != Qnil) {
		yajl_check_and_fire_callback((void *)self);
		return Qnil;
	}

	return rb_ary_pop(wrapper->builderStack);
}
/*
* Document-method: parse_chunk
*
* call-seq: parse_chunk(string_chunk)
*
* +string_chunk+ can be a partial or full JSON string to push on the parser.
*
* This method will throw an exception if the +on_parse_complete+ callback hasn't been assigned yet.
* The +on_parse_complete+ callback assignment is required so the user can handle objects that have been
* parsed off the stream as they're found.
*/
static VALUE rb_yajl_parser_parse_chunk(VALUE self, VALUE chunk) {
	yajl_parser_wrapper * wrapper;
	unsigned int len;

	GetParser(self, wrapper);
	if (NIL_P(chunk)) {
		rb_raise(cParseError, "Can't parse a nil string.");
	}

	if (wrapper->parse_complete_callback != Qnil) {
		const char * cptr = RSTRING_PTR(chunk);
		len = RSTRING_LEN(chunk);
		yajl_parse_chunk((const unsigned char*)cptr, len, wrapper->parser);
	} else {
		rb_raise(cParseError, "The on_parse_complete callback isn't setup, parsing useless.");
	}

	return Qnil;
}

void _yajl_ruby_init_parser() {
	cParseError = rb_define_class_under(mYajl, "ParseError", rb_eStandardError);

	cParser = rb_define_class_under(mYajl, "Parser", rb_cObject);

	rb_define_alloc_func(cParser, allocate);

	rb_define_method(cParser, "initialize", rb_yajl_parser_init, -1);
	rb_define_method(cParser, "parse", rb_yajl_parser_parse, -1);
	rb_define_method(cParser, "parse_chunk", rb_yajl_parser_parse_chunk, 1);
	rb_define_method(cParser, "<<", rb_yajl_parser_parse_chunk, 1);
	rb_define_method(cParser, "on_parse_complete=", rb_yajl_parser_set_complete_cb, 1);

	intern_io_read = rb_intern("read");
	sym_allow_comments = ID2SYM(rb_intern("allow_comments"));
	sym_check_utf8 = ID2SYM(rb_intern("check_utf8"));
	sym_symbolize_keys = ID2SYM(rb_intern("symbolize_keys"));
}
