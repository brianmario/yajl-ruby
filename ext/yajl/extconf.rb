require 'mkmf'
require 'rbconfig'

$CFLAGS << ' -Wall -funroll-loops -Wno-declaration-after-statement'
$CFLAGS << ' -Werror-implicit-function-declaration -Wextra -O0 -ggdb3' if ENV['DEBUG']

create_makefile('yajl/yajl')
