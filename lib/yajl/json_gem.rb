# encoding: UTF-8
require 'yajl' unless defined?(Yajl::Parser)
require 'yajl/json_gem/parsing'
require 'yajl/json_gem/encoding'

module ::Kernel
  def JSON(object, opts = {})
    if object.respond_to? :to_s
      JSON.parse(object.to_s, opts)
    else
      JSON.generate(object, opts)
    end
  end
end