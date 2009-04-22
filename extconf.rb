require 'mkmf'
dir_config('yajl')
have_header('yajl/yajl_parse.h')
have_header('yajl/yajl_gen.h')
have_library('yajl')
create_makefile("yajl")