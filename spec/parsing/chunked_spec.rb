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
    @parser = Yajl::Parser.new
    @parser.on_parse_complete = @callback
  end
  
  it "should parse a single chunk" do
    @callback.should_receive(:call).with(@final)
    @parser << '[{"abc": 123},{"def": 456}]'
  end
  
  it "should parse a single chunk, 3 times" do
    @callback.should_receive(:call).with(@final).exactly(3).times
    @parser << '[{"abc": 123},{"def": 456}]'
    @parser << '[{"abc": 123},{"def": 456}]'
    @parser << '[{"abc": 123},{"def": 456}]'
  end
  
  it "should parse in two chunks" do
    @callback.should_receive(:call).with(@final)
    @parser << '[{"abc": 123},'
    @parser << '{"def": 456}]'
  end
  
  it "should parse in 2 chunks, twice" do
    @callback.should_receive(:call).with(@final).exactly(2).times
    @parser << '[{"abc": 123},'
    @parser << '{"def": 456}]'
    @parser << '[{"abc": 123},'
    @parser << '{"def": 456}]'
  end
  
  it "should parse 2 JSON strings, in 3 chunks" do
    @callback.should_receive(:call).with(@final).exactly(2).times
    @parser << '[{"abc": 123},'
    @parser << '{"def": 456}][{"abc": 123},{"def":'
    @parser << ' 456}]'
  end
  
  it "should parse 2 JSON strings in 1 chunk" do
    @callback.should_receive(:call).with(@final).exactly(2).times
    @parser << '[{"abc": 123},{"def": 456}][{"abc": 123},{"def": 456}]'
  end
  
  it "should parse 2 JSON strings from an IO" do
    @callback.should_receive(:call).with(@final).exactly(2).times
    @parser.parse(StringIO.new('[{"abc": 123},{"def": 456}][{"abc": 123},{"def": 456}]'))
  end
  
  it "should parse a JSON string an IO and fire callback once" do
    @callback.should_receive(:call).with(@final)
    @parser.parse(StringIO.new('[{"abc": 123},{"def": 456}]'))
  end
  
  it "should parse twitter_stream.json and fire callback 430 times" do
    path = File.expand_path(File.dirname(__FILE__) + '/../../benchmark/subjects/twitter_stream.json')
    json = File.new(path, 'r')
    @callback.should_receive(:call).exactly(430).times
    @parser.parse(json)
  end
end