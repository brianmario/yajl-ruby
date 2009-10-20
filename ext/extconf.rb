# encoding: UTF-8
require 'mkmf'
require 'rbconfig'

$CFLAGS << ' -Wall'
# $CFLAGS << ' -O0 -ggdb'

create_makefile("yajl_ext")
