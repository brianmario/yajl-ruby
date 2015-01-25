require 'mkmf'
require 'rbconfig'

if RbConfig::CONFIG['host_os'] =~ /win(32|64)/
  $CFLAGS << ' /Od /Zi' if ENV['DEBUG']
else
  $CFLAGS << ' -Wall -funroll-loops'
  $CFLAGS << ' -Werror-implicit-function-declaration -Wextra -O0 -ggdb3' if ENV['DEBUG']
end

create_makefile('yajl/yajl')
