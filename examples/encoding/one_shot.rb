# encoding: UTF-8

require 'rubygems'
require 'yajl'

obj = {
  :a_test => "of encoding in one pass",
  :which_will => "simply return a string when finished",
  :as_easy_as => 123
}

str = Yajl::Encoder.encode(obj)
puts str