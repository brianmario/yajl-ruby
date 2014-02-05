require 'mkmf'
require 'rbconfig'

$CFLAGS << ' -Wall -funroll-loops' unless $mswin
$CFLAGS << ' -Wextra -O0 -ggdb3' if ENV['DEBUG'] && !$mswin

create_makefile('yajl/yajl')
