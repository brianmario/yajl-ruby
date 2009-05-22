# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')
require 'stringio'

describe "Chunked parser" do
  before(:all) do
    @final = [{"abc" => 123}, {"def" => 456}]
  end
  
  before(:each) do
    @callback = lambda { |hash|
      # no-op
    }
    Yajl::Chunked.on_parse_complete = @callback
  end
  
  after(:each) do
    Yajl::Chunked.on_parse_complete = nil
  end
  
  it "should parse a single chunk" do
    @callback.should_receive(:call).with(@final)
    Yajl::Chunked << '[{"abc": 123},{"def": 456}]'
  end
  
  it "should parse a single chunk, 3 times" do
    @callback.should_receive(:call).with(@final).exactly(3).times
    Yajl::Chunked << '[{"abc": 123},{"def": 456}]'
    Yajl::Chunked << '[{"abc": 123},{"def": 456}]'
    Yajl::Chunked << '[{"abc": 123},{"def": 456}]'
  end
  
  it "should parse in two chunks" do
    @callback.should_receive(:call).with(@final)
    Yajl::Chunked << '[{"abc": 123},'
    Yajl::Chunked << '{"def": 456}]'
  end
  
  it "should parse in 2 chunks, twice" do
    @callback.should_receive(:call).with(@final).exactly(2).times
    Yajl::Chunked << '[{"abc": 123},'
    Yajl::Chunked << '{"def": 456}]'
    Yajl::Chunked << '[{"abc": 123},'
    Yajl::Chunked << '{"def": 456}]'
  end
  
  it "should parse 2 JSON strings, in 3 chunks" do
    @callback.should_receive(:call).with(@final).exactly(2).times
    Yajl::Chunked << '[{"abc": 123},'
    Yajl::Chunked << '{"def": 456}][{"abc": 123},{"def":'
    Yajl::Chunked << ' 456}]'
  end
  
  it "should parse 2 JSON strings in 1 chunk" do
    @callback.should_receive(:call).with(@final).exactly(2).times
    Yajl::Chunked << '[{"abc": 123},{"def": 456}][{"abc": 123},{"def": 456}]'
  end
  
  it "should parse 2 JSON strings from an IO" do
    @callback.should_receive(:call).with(@final).exactly(2).times
    Yajl::Stream.parse(StringIO.new('[{"abc": 123},{"def": 456}][{"abc": 123},{"def": 456}]'))
  end
  
  it "should parse a JSON string an IO and fire callback once" do
    @callback.should_receive(:call).with(@final)
    Yajl::Stream.parse(StringIO.new('[{"abc": 123},{"def": 456}]'))
  end
end