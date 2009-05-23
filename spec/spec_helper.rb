# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

begin
  require './yajl_ext'
  require 'yajl'
rescue LoadError
  require 'yajl'
end
require 'stringio'
require 'active_support/core_ext/kernel/reporting'