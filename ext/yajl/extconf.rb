require 'mkmf'

yajl_dir = File.join($srcdir, 'vendor')

$CFLAGS << " -Wall -I#{yajl_dir}"
$CFLAGS << ' -Wextra -O0 -ggdb3' if ENV['DEBUG']

srcs = Dir[File.join(yajl_dir, '*.c')] + Dir[File.join(File.expand_path('..', __FILE__), '*.c')]
$objs = srcs.map {|src| File.basename(src).gsub(/\.c$/, '.o') }

$VPATH << "$(srcdir)/vendor"

create_makefile('yajl/yajl')
