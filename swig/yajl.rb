require 'yajl.bundle'

io = File.new('json/search.json', File::RDONLY | File::NONBLOCK)

config = Yajl::Yajl_parser_config.new
config.allowComments = 1
config.checkUTF8 = 1

callbacks = Yajl::Yajl_callbacks.new
context = {}

parser = Yajl.yajl_alloc(callbacks, config, nil, nil)

bytes = ''
while io.read(65536, bytes)
  status = Yajl.yajl_parse(parser, bytes, bytes.size)

  if status != 0 && status != 2
    error = Yajl.yajl_status_to_string(status)
    error_str = Yajl.yajl_get_error(parser, 1, bytes, bytes.size)
    puts bytes
    puts error_str
    Yajl.yajl_free_error(parser, error_str)
    break
  end

end

Yajl.yajl_parse_complete(parser)
Yajl.yajl_free(parser)