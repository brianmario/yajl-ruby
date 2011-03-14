# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe "Nested parsing" do
  before(:each) do
    @nested_callback = lambda { |hash,depth|
      # no-op
    }
  end

  it "should parse a single nested hash" do
    @parser = Yajl::Parser.new(:process_nested => true, :nested_depth => 1)
    @parser.on_parse_nested = @nested_callback
    
    @nested_callback.should_receive(:call).with({"abc" => 123},1)
    @parser << '[{"abc": 123}]'
  end
  
  
  it "should parse a two-layer array" do
    @parser = Yajl::Parser.new(:process_nested => true, :nested_depth => 2)
    @parser.on_parse_nested = @nested_callback
    
    @nested_callback.should_receive(:call).with({"abc" => 123},2)
    @nested_callback.should_receive(:call).with([{"abc" => 123}],1)
    @parser << '[[{"abc": 123}]]'
  end
  
  
  it "should parse a single-layer array multiple times" do
    @parser = Yajl::Parser.new(:process_nested => true, :nested_depth => 1)
    @parser.on_parse_nested = @nested_callback
    
    @nested_callback.should_receive(:call).with({"abc" => 123},1)
    @nested_callback.should_receive(:call).with({"def" => 456},1)
    @parser << '[{"abc": 123},{"def": 456}]'
  end
  
  
  it "should handle a nested depth of 0" do
    @parser = Yajl::Parser.new(:process_nested => true, :nested_depth => 0)
    @parser.on_parse_nested = @nested_callback
    
    @nested_callback.should_receive(:call).with({"abc" => 123},2)
    @nested_callback.should_receive(:call).with([{"abc" => 123}],1)
    @parser << '[[{"abc": 123}]]'
  end
end