# encoding: UTF-8
require 'mkmf'
require 'rbconfig'

$CFLAGS << ' -Wall'

create_makefile("yajl_ext")