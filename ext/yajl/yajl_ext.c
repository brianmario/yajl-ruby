#include "common.h"

VALUE mYajl;
ID intern_call, intern_has_key, intern_keys, intern_to_s, intern_to_json;
ID sym_pretty, sym_indent, sym_terminator, sym_html_safe;

extern void _yajl_ruby_init_encoder();
extern void _yajl_ruby_init_parser();

/* Ruby Extension initializer */
void Init_yajl() {
    mYajl = rb_define_module("Yajl");

    _yajl_ruby_init_encoder();
    _yajl_ruby_init_parser();

    intern_call = rb_intern("call");

#ifdef HAVE_RUBY_ENCODING_H
    utf8Encoding = rb_utf8_encoding();
#endif
}
