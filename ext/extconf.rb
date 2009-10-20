# encoding: UTF-8
require 'mkmf'
require 'rbconfig'

$CFLAGS << ' -Wall -O3'
# $CFLAGS << ' -O0 -ggdb'

create_makefile("yajl_ext")
