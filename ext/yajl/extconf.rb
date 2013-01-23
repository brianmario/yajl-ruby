require 'mkmf'

yajl_dir = File.join($srcdir, 'vendor')

$CFLAGS << " -Wall -I#{yajl_dir}"
$CFLAGS << ' -Wextra -O0 -ggdb3' if ENV['DEBUG']

if have_library("yajl", nil, 'yajl/yajl_common.h')
  find_header("yajl_common.h", File.join($hdrdir, 'yajl'))
else
  srcs = Dir[File.join(yajl_dir, '*.c')] + Dir[File.join(File.expand_path('..', __FILE__), '*.c')]
  $objs = srcs.map {|src| File.basename(src).gsub(/\.c$/, '.o') }

  $VPATH << "$(srcdir)/vendor"

  find_header("yajl_common.h", File.join(yajl_dir, 'api'))
end

create_makefile('yajl/yajl')
