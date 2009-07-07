# encoding: UTF-8

require 'rubygems'
require 'yajl'

obj = {
  :a_test => "of encoding directly to an IO stream",
  :which_will => "simply return a string when finished",
  :as_easy_as => 123
}

Yajl::Encoder.encode(obj, STDOUT)