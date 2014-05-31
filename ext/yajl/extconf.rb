require 'mkmf'
require 'rbconfig'

$CFLAGS << ' -Wall -funroll-loops'
$CFLAGS << ' -Werror-implicit-function-declaration -Wextra -O0 -ggdb3' if ENV['DEBUG']

create_makefile('yajl/yajl')
