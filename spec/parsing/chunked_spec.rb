# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')
require 'stringio'
describe "Chunked parser" do
  before(:all) do
    @final = [{"abc" => 123}, {"def" => 456}]
  end
  
  before(:each) do
    @callback = lambda { |hash| 
      puts hash.inspect
      hash.should == @final
    }
    Yajl::Chunked.on_parse_complete = @callback
  end
  
  it "should parse a single chunk" do
    @callback.should_receive(:call)
    Yajl::Chunked << '[{"abc": 123},{"def": 456}]'
  end
  
  it "should parse a single chunk, 3 times" do
    @callback.should_receive(:call).exactly(3).times
    Yajl::Chunked << '[{"abc": 123},{"def": 456}]'
    Yajl::Chunked << '[{"abc": 123},{"def": 456}]'
    Yajl::Chunked << '[{"abc": 123},{"def": 456}]'
  end
  
  it "should parse in two chunks" do
    @callback.should_receive(:call)
    Yajl::Chunked << '[{"abc": 123},'
    Yajl::Chunked << '{"def": 456}]'
  end
  
  it "should parse in 2 chunks, twice" do
    @callback.should_receive(:call).exactly(2).times
    Yajl::Chunked << '[{"abc": 123},'
    Yajl::Chunked << '{"def": 456}]'
    Yajl::Chunked << '[{"abc": 123},'
    Yajl::Chunked << '{"def": 456}]'
  end
  
  it "should parse 2 JSON strings, in 3 chunks" do
    @callback.should_receive(:call).exactly(2).times
    Yajl::Chunked << '[{"abc": 123},'
    Yajl::Chunked << '{"def": 456}][{"abc": 123},{"def":'
    Yajl::Chunked << ' 456}]'
  end
  
  it "should parse 2 JSON strings in 1 chunk" do
    pending
    @callback.should_receive(:call).exactly(2).times
    Yajl::Chunked << '[{"abc": 123},{"def": 456}][{"abc": 123},{"def": 456}]'
  end
  
  it "should parse 2 JSON strings from an IO" do
    pending
    @callback.should_receive(:call).exactly(2).times
    Yajl::Stream.parse(StringIO.new('[{"abc": 123},{"def": 456}][{"abc": 123},{"def": 456}]'))
  end
  
  it "should parse an IO" do
    @callback.should_receive(:call)
    Yajl::Stream.parse(StringIO.new('[{"abc": 123},{"def": 456}]'))
  end
end