# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

class Dummy; end

describe "JSON Gem compatability API" do
  it "shoud not mixin #to_json on base objects until Yajl::Encoder.enable_json_gem_compatability has been called" do
    d = Dummy.new
    
    d.respond_to?(:to_json).should_not be_true
    "".respond_to?(:to_json).should_not be_true
    1.respond_to?(:to_json).should_not be_true
    "1.5".to_f.respond_to?(:to_json).should_not be_true
    [].respond_to?(:to_json).should_not be_true
    {:foo => "bar"}.respond_to?(:to_json).should_not be_true
    true.respond_to?(:to_json).should_not be_true
    false.respond_to?(:to_json).should_not be_true
    nil.respond_to?(:to_json).should_not be_true
  end
  
  it "should mixin #to_json on base objects after Yajl::Encoder.enable_json_gem_compatability has been called" do
    Yajl::Encoder.enable_json_gem_compatability
    d = Dummy.new
    
    d.respond_to?(:to_json).should be_true
    "".respond_to?(:to_json).should be_true
    1.respond_to?(:to_json).should be_true
    "1.5".to_f.respond_to?(:to_json).should be_true
    [].respond_to?(:to_json).should be_true
    {:foo => "bar"}.respond_to?(:to_json).should be_true
    true.respond_to?(:to_json).should be_true
    false.respond_to?(:to_json).should be_true
    nil.respond_to?(:to_json).should be_true
  end
  
  it "should require yajl/json_gem to enable the compatability API" do
    require 'yajl/json_gem'
    
    defined?(JSON).should be_true
    
    JSON.respond_to?(:parse).should be_true
    JSON.respond_to?(:generate).should be_true
    JSON.respond_to?(:pretty_generate).should be_true
    JSON.respond_to?(:load).should be_true
    JSON.respond_to?(:dump).should be_true
  end
end