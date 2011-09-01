# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe "Parser with callbacks" do
  before :each do
    @callback0 = lambda { }
    @callback1 = lambda { |arg| }
    @parser = Yajl::Parser.new
  end

  it 'should notify when reading a key' do
    @parser.on_key = @callback1
    keys = ['abc', 'def']
    @callback1.should_receive(:call).exactly(keys.count).times do |key|
      key.should == keys.shift
    end
    @parser.parse '[{"abc": 123},{"def": 456},{}]'
  end

  it 'should notify when reading a value' do
    @parser.on_value = @callback1
    values = [123, 456, 'ghi', 7.89]
    @callback1.should_receive(:call).exactly(values.count).times do |value|
      value.should == values.shift
    end
    @parser.parse '[{"abc": 123},{"def": [456, "ghi", 7.89]},{"jkl":{}}]'
  end

  it 'should notify when reading a new object' do
    @parser.on_object_begin = @callback0
    @callback0.should_receive(:call).exactly(4).times
    @parser.parse '[{"abc": 123},{"def": [456, "ghi", 7.89]},{"jkl":{}}]'
  end

  it 'should notify when having parsed a new object' do
    @parser.on_object_end = @callback0
    @callback0.should_receive(:call).exactly(4).times
    @parser.parse '[{"abc": 123},{"def": [456, "ghi", 7.89]},{"jkl":{}}]'
  end

  it 'should notify in the correct order' do
    @parser.on_object_begin = @object_begin = lambda { }
    @parser.on_key = @key = lambda { |k| }
    @parser.on_value = @value = lambda { |v| }
    @parser.on_object_end = @object_end = lambda { }

    @object_begin.should_receive(:call).ordered
    @key.should_receive(:call).ordered
    @value.should_receive(:call).ordered
    @object_end.should_receive(:call).ordered

    @parser.parse '[{"key": "value"}]'
  end
end