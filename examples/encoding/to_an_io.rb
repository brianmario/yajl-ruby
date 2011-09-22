$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)

require 'yajl'

obj = {
  :a_test => "of encoding directly to an IO stream",
  :which_will => "simply return a string when finished",
  :as_easy_as => 123
}

Yajl::Encoder.encode(obj, STDOUT)