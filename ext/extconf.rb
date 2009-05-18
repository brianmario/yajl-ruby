# encoding: UTF-8
require 'mkmf'
require 'rbconfig'

dir_config('yajl')
have_header('yajl/yajl_parse.h')
have_header('yajl/yajl_gen.h')

if have_library("yajl")
  # $CFLAGS << ' -static'
  # $LDFLAGS << ' -read_only_relocs suppress'
  create_makefile("yajl_ext")
else
  puts "Yajl not found, maybe try manually specifying --with-yajl-dir to find it?"
end