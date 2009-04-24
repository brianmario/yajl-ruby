require 'mkmf'
dir_config('yajl')
have_header('yajl/yajl_parse.h')
have_header('yajl/yajl_gen.h')

if have_library("yajl")
  create_makefile("yajl")
else
  puts "Yajl not found, maybe try manually specifying --with-yajl-dir to find it?"
end