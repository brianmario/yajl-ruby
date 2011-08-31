# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe "Parser with callbacks" do
  before :each do
    @callback = lambda { |hash|
      # no-op
    }
    @parser = Yajl::Parser.new
  end

  it 'should notify when reading a key' do
    @parser.on_key = @callback
    keys = ['abc', 'def']
    @callback.should_receive(:call).exactly(keys.count).times do |key|
      key.should == keys.shift
    end
    @parser.parse '[{"abc": 123},{"def": 456},{}]'
  end

  it 'should notify when reading a value' do
    @parser.on_value = @callback
    values = [123, 456, 'ghi', 7.89]
    @callback.should_receive(:call).exactly(values.count).times do |value|
      value.should == values.shift
    end
    @parser.parse '[{"abc": 123},{"def": [456, "ghi", 7.89]},{"jkl":{}}]'
  end
end