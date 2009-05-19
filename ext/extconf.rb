# encoding: UTF-8
require 'mkmf'
require 'rbconfig'

# $CFLAGS << ' -Wall'
$CFLAGS << ' -static'
$LDFLAGS << ' -read_only_relocs suppress'

create_makefile("yajl_ext")
