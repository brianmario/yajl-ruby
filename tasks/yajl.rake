namespace :yajl do
  dir = File.expand_path('../../vendor/yajl', __FILE__)

  desc "Clone or update upstream yajl sources into vendor/yajl"
  task :update do
    if File.exist? dir
      `cd #{dir}; git pull`
    else
      `git clone git@github.com:brianmario/yajl.git #{dir} -b yajl-ruby-2.0`
    end
  end

  desc "Copy upstream yajl sources from vendor/yajl into ext/yajl/vendor"
  task :embed do
    # make sure we've generated yajl_version.h
    `cd #{dir}; cmake .`

    # copy and process headers
    header_src_dir = Dir[File.join(dir, 'yajl-*/include/yajl')].last
    header_dst_dir = File.expand_path('../../ext/yajl/vendor/api', __FILE__)
    `mkdir -p #{header_dst_dir}`

    # we need to update the include path since we're embedding the source
    Dir[File.join(header_src_dir, '*.h')].each do |header|
      contents = File.read(header)
      updated = contents.gsub(/\#include <yajl\//, '#include <api/')
      filename = File.basename(header)
      file = File.new File.join(header_dst_dir, filename), 'w+'
      file.write(updated)
      file.close
    end

    # copy the rest of yajl's sources over
    yajl_src_dir   = File.expand_path('../../vendor/yajl/src', __FILE__)
    yajl_dst_dir   = File.expand_path('../../ext/yajl/vendor', __FILE__)
    `cd #{dir}; cp #{yajl_src_dir}/*.h #{yajl_dst_dir}`
    `cd #{dir}; cp #{yajl_src_dir}/*.c #{yajl_dst_dir}`

    # don't forget to update yajl_version.c too
    yajl_version_c = File.expand_path('../../ext/yajl/vendor/yajl_version.c', __FILE__)
    contents = File.read(yajl_version_c)
    updated = contents.gsub(/\#include <yajl\//, '#include <api/')
    file = File.new yajl_version_c, 'w+'
    file.write(updated)
    file.close
  end
end