puts "DEPRECATION WARNING: Yajl's JSON gem compatibility API is going to be removed in 2.0"

require 'yajl' unless defined?(Yajl::Parser)
require 'yajl/json_gem/parsing'
require 'yajl/json_gem/encoding'

module ::Kernel
  def JSON(object, opts = {})
    if object.respond_to? :to_s
      JSON.parse(object.to_s, JSON.default_options.merge(opts))
    else
      JSON.generate(object, opts)
    end
  end
end