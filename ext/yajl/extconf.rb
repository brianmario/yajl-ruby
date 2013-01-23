require 'mkmf'


$CFLAGS << " -Wall"
$CFLAGS << ' -Wextra -O0 -ggdb3' if ENV['DEBUG']

def find_yajl_headers(path)
  ['yajl_gen.h', 'yajl_parse.h'].each do |header|
    find_header(header, path)
  end
end

if have_library("yajl", nil, 'yajl/yajl_common.h')
  find_yajl_headers(File.join($hdrdir, 'yajl'))
else
  yajl_dir = File.join($srcdir, 'vendor')

  srcs = Dir[File.join(yajl_dir, '*.c')] + Dir[File.join(File.expand_path('..', __FILE__), '*.c')]
  $objs = srcs.map {|src| File.basename(src).gsub(/\.c$/, '.o') }

  $INCFLAGS << " -I#{yajl_dir}"
  $VPATH << "$(srcdir)/vendor"

  find_yajl_headers(File.join(yajl_dir, 'api'))
end

create_makefile('yajl/yajl')
