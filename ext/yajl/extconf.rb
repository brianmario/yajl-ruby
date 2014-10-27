require 'mkmf'
require 'rbconfig'

if RbConfig::CONFIG['host_os'] =~ /solaris(!?2\.1[0-2])/
  if RbConfig::CONFIG['GCC'] != ""
    $CFLAGS << ' -Wall -funroll-loops'
    $CFLAGS << ' -Werror-implicit-function-declaration -Wextra -O0 -ggdb3' if ENV['DEBUG']
  end
end

create_makefile('yajl/yajl')
