require 'mkmf'

yajl_dir = File.expand_path('../vendor', __FILE__)

$CFLAGS << " -Wall -I#{yajl_dir}"
$CFLAGS << ' -Wextra -O0 -ggdb3' if ENV['DEBUG']

srcs = Dir[File.join(yajl_dir, '*.c')] + Dir[File.join(File.expand_path('..', __FILE__), '*.c')]
$objs = srcs.map {|src| File.basename(src).gsub(/\.c$/, '.o') }

create_makefile('yajl/yajl')

# now lets post-process the Makefile so we compile the vendored yajl too
m = File.read('Makefile')
m.gsub!(/VPATH = (.*)\n/, "VPATH = \\1#{CONFIG['PATH_SEPARATOR']}#{yajl_dir}\n")
File.open('Makefile', 'w+') {|f| f.write(m) }
