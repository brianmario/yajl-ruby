#include "common.h"
#include "api/yajl_gen.h"

#define WRITE_BUFSIZE 8192
#define GetEncoder(obj, sval) (sval = (yajl_encoder_wrapper*)DATA_PTR(obj));

extern VALUE mYajl;
extern ID intern_call;
static ID sym_pretty, sym_indent, sym_terminator, sym_html_safe;
static ID intern_as_json, intern_has_key, intern_keys, intern_to_s, intern_to_json;
static VALUE cEncodeError, cEncoder;

static unsigned char *defaultIndentString = (unsigned char *)"  ";

typedef struct {
	VALUE on_progress_callback;
	VALUE terminator;
	yajl_gen encoder;
	unsigned char *indentString;
} yajl_encoder_wrapper;

void yajl_encode_part(void * wrapper, VALUE obj, VALUE io) {
	VALUE str, outBuff, otherObj;
	yajl_encoder_wrapper * w = wrapper;
	yajl_gen_status status;
	int idx = 0;
	const unsigned char * buffer;
	const char * cptr;
	size_t len;
	VALUE keys, entry, keyStr;

	if (io != Qnil || w->on_progress_callback != Qnil) {
		status = yajl_gen_get_buf(w->encoder, &buffer, &len);
		if (len >= WRITE_BUFSIZE) {
			outBuff = rb_str_new((const char *)buffer, len);
			if (io != Qnil) {
				rb_io_write(io, outBuff);
			} else if (w->on_progress_callback != Qnil) {
				rb_funcall(w->on_progress_callback, intern_call, 1, outBuff);
			}
			yajl_gen_clear(w->encoder);
		}
	}

	switch (TYPE(obj)) {
		case T_HASH:
		status = yajl_gen_map_open(w->encoder);

						/* TODO: itterate through keys in the hash */
		keys = rb_funcall(obj, intern_keys, 0);
		for(idx=0; idx<RARRAY_LEN(keys); idx++) {
			entry = rb_ary_entry(keys, idx);
			keyStr = rb_funcall(entry, intern_to_s, 0); /* key must be a string */
								/* the key */
			yajl_encode_part(w, keyStr, io);
								/* the value */
			yajl_encode_part(w, rb_hash_aref(obj, entry), io);
		}

		status = yajl_gen_map_close(w->encoder);
		break;
		case T_ARRAY:
		status = yajl_gen_array_open(w->encoder);
		for(idx=0; idx<RARRAY_LEN(obj); idx++) {
			otherObj = rb_ary_entry(obj, idx);
			yajl_encode_part(w, otherObj, io);
		}
		status = yajl_gen_array_close(w->encoder);
		break;
		case T_NIL:
		status = yajl_gen_null(w->encoder);
		break;
		case T_TRUE:
		status = yajl_gen_bool(w->encoder, 1);
		break;
		case T_FALSE:
		status = yajl_gen_bool(w->encoder, 0);
		break;
		case T_FIXNUM:
		case T_FLOAT:
		case T_BIGNUM:
		str = rb_funcall(obj, intern_to_s, 0);
		cptr = RSTRING_PTR(str);
		len = RSTRING_LEN(str);
		if (memcmp(cptr, "NaN", 3) == 0 || memcmp(cptr, "Infinity", 8) == 0 || memcmp(cptr, "-Infinity", 9) == 0) {
			rb_raise(cEncodeError, "'%s' is an invalid number", cptr);
		}
		status = yajl_gen_number(w->encoder, cptr, len);
		break;
		case T_STRING:
		cptr = RSTRING_PTR(obj);
		len = RSTRING_LEN(obj);
		status = yajl_gen_string(w->encoder, (const unsigned char *)cptr, len);
		break;
		default:
		if (rb_respond_to(obj, intern_to_json)) {
			str = rb_funcall(obj, intern_to_json, 0);
			Check_Type(str, T_STRING);
			cptr = RSTRING_PTR(str);
			len = RSTRING_LEN(str);
			status = yajl_gen_number(w->encoder, cptr, len);
		} else {
			str = rb_funcall(obj, intern_to_s, 0);
			Check_Type(str, T_STRING);
			cptr = RSTRING_PTR(str);
			len = RSTRING_LEN(str);
			status = yajl_gen_string(w->encoder, (const unsigned char *)cptr, len);
		}
		break;
	}
}
static void yajl_encoder_wrapper_free(void *wrapper) {
	yajl_encoder_wrapper *w = wrapper;
	if (w) {
		if (w->indentString) {
			free(w->indentString);
		}
		yajl_gen_free(w->encoder);
		free(w);
	}
}
static void yajl_encoder_wrapper_mark(void *wrapper) {
	yajl_encoder_wrapper *w = wrapper;
	if (w) {
		rb_gc_mark(w->on_progress_callback);
		rb_gc_mark(w->terminator);
	}
}
static VALUE allocate(VALUE klass) {
	yajl_encoder_wrapper *wrapper;
	VALUE obj;

	wrapper = malloc(sizeof(yajl_encoder_wrapper));

	wrapper->encoder = yajl_gen_alloc(NULL);

	obj = Data_Wrap_Struct(klass, yajl_encoder_wrapper_mark, yajl_encoder_wrapper_free, wrapper);

	return obj;
}

/*
 * Document-class: Yajl::Encoder
 *
 * This class contains methods for encoding a Ruby object into JSON, streaming it's output into an IO object.
 * The IO object need only respond to #write(str)
 * The JSON stream created is written to the IO in chunks, as it's being created.
 */
/*
 * Document-method: initialize
 *
 * call-seq: initialize([:pretty => false[, :indent => '  '][, :terminator => "\n"]])
 *
 * :pretty will enable/disable beautifying or "pretty priting" the output string.
 *
 * :indent is the character(s) used to indent the output string.
 *
 * :terminator allows you to specify a character to be used as the termination character after a full JSON string has
 * the encoder. This would be especially useful when encoding in chunks (via a block or callback during the encode pr
 * determine when the last chunk of the current encode is sent.
 * If you specify this option to be nil, it will be ignored if encoding directly to an IO or simply returning a strin
 * the encoder will still pass it - I hope that makes sense ;).
 */
static VALUE rb_yajl_encoder_init(int argc, VALUE * argv, VALUE self) {
	yajl_encoder_wrapper *wrapper;
	VALUE opts, indent;
	unsigned char *indentString = NULL, *actualIndent = NULL;
	int beautify = 0, htmlSafe = 0;

	GetEncoder(self, wrapper);

		/* Scan off config vars */
	if (rb_scan_args(argc, argv, "01", &opts) == 1) {
		Check_Type(opts, T_HASH);

		if (rb_hash_aref(opts, sym_pretty) == Qtrue) {
			beautify = 1;
			indent = rb_hash_aref(opts, sym_indent);
			if (indent != Qnil) {
#ifdef HAVE_RUBY_ENCODING_H
				indent = rb_str_export_to_enc(indent, utf8Encoding);
#endif
				Check_Type(indent, T_STRING);
				indentString = (unsigned char*)malloc(RSTRING_LEN(indent)+1);
				memcpy(indentString, RSTRING_PTR(indent), RSTRING_LEN(indent));
				indentString[RSTRING_LEN(indent)] = '\0';
				actualIndent = indentString;
			}
		}
		if (rb_hash_aref(opts, sym_html_safe) == Qtrue) {
			htmlSafe = 1;
		}
	}
	if (!indentString) {
		indentString = defaultIndentString;
	}

	yajl_gen_config(wrapper->encoder, yajl_gen_beautify, beautify);
	yajl_gen_config(wrapper->encoder, yajl_gen_indent_string, indentString);
	yajl_gen_config(wrapper->encoder, yajl_gen_escape_solidus, htmlSafe);

	wrapper->indentString = actualIndent;
	wrapper->on_progress_callback = Qnil;
	if (opts != Qnil && rb_funcall(opts, intern_has_key, 1, sym_terminator) == Qtrue) {
		wrapper->terminator = rb_hash_aref(opts, sym_terminator);
#ifdef HAVE_RUBY_ENCODING_H
		if (TYPE(wrapper->terminator) == T_STRING) {
			wrapper->terminator = rb_str_export_to_enc(wrapper->terminator, utf8Encoding);
		}
#endif
	} else {
		wrapper->terminator = 0;
	}
	return self;
}
/*
 * Document-method: encode
 *
 * call-seq: encode(obj[, io[, &block]])
 *
 * +obj+ is the Ruby object to encode to JSON
 *
 * +io+ is an optional IO used to stream the encoded JSON string to.
 * If +io+ isn't specified, this method will return the resulting JSON string. If +io+ is specified, this method returns nil
 *
 * If an optional block is passed, it's called when encoding is complete and passed the resulting JSON string
 *
 * It should be noted that you can reuse an instance of this class to continue encoding multiple JSON
 * to the same stream. Just continue calling this method, passing it the same IO object with new/different
 * ruby objects to encode. This is how streaming is accomplished.
 */
static VALUE rb_yajl_encoder_encode(int argc, VALUE * argv, VALUE self) {
	yajl_encoder_wrapper * wrapper;
	const unsigned char * buffer;
	size_t len;
	VALUE obj, io, blk, outBuff;

	GetEncoder(self, wrapper);

	rb_scan_args(argc, argv, "11&", &obj, &io, &blk);

	if (blk != Qnil) {
		wrapper->on_progress_callback = blk;
	}

	yajl_gen_reset(wrapper->encoder);
	/* begin encode process */
	yajl_encode_part(wrapper, obj, io);

	/* just make sure we output the remaining buffer */
	yajl_gen_get_buf(wrapper->encoder, &buffer, &len);
	outBuff = rb_str_new((const char *)buffer, len);
#ifdef HAVE_RUBY_ENCODING_H
	rb_enc_associate(outBuff, utf8Encoding);
#endif
	yajl_gen_clear(wrapper->encoder);

	if (io != Qnil) {
		rb_io_write(io, outBuff);
		if (wrapper->terminator != 0 && wrapper->terminator != Qnil) {
			rb_io_write(io, wrapper->terminator);
		}
		return Qnil;
	} else if (blk != Qnil) {
		rb_funcall(blk, intern_call, 1, outBuff);
		if (wrapper->terminator != 0) {
			rb_funcall(blk, intern_call, 1, wrapper->terminator);
		}
		return Qnil;
	} else {
		if (wrapper->terminator != 0 && wrapper->terminator != Qnil) {
			rb_str_concat(outBuff, wrapper->terminator);
		}
		return outBuff;
	}
	return Qnil;
}
/*
 * Document-method: on_progress
 *
 * call-seq: on_progress = Proc.new {|str| ...}
 *
 * This callback setter allows you to pass a Proc/lambda or any other object that responds to #call.
 *
 * It will pass the caller a chunk of the encode buffer after it's reached it's internal max buffer size (defaults to 8kb).
 * For example, encoding a large object that would normally result in 24288 bytes of data will result in 3 calls to this callback (assuming the 8kb default encode buffer).
 */
static VALUE rb_yajl_encoder_set_progress_cb(VALUE self, VALUE callback) {
    yajl_encoder_wrapper * wrapper;
    GetEncoder(self, wrapper);
    wrapper->on_progress_callback = callback;
    return Qnil;
}

void _yajl_ruby_init_encoder() {
	cEncodeError = rb_define_class_under(mYajl, "EncodeError", rb_eStandardError);

	cEncoder = rb_define_class_under(mYajl, "Encoder", rb_cObject);

	rb_define_alloc_func(cEncoder, allocate);

	rb_define_method(cEncoder, "initialize", rb_yajl_encoder_init, -1);
	rb_define_method(cEncoder, "encode", rb_yajl_encoder_encode, -1);
	rb_define_method(cEncoder, "on_progress=", rb_yajl_encoder_set_progress_cb, 1);

	intern_as_json = rb_intern("as_json");
	intern_keys = rb_intern("keys");
	intern_to_s = rb_intern("to_s");
	intern_to_json = rb_intern("to_json");
	intern_has_key = rb_intern("has_key?");

	sym_pretty = ID2SYM(rb_intern("pretty"));
	sym_indent = ID2SYM(rb_intern("indent"));
	sym_html_safe = ID2SYM(rb_intern("html_safe"));
	sym_terminator = ID2SYM(rb_intern("terminator"));
}
