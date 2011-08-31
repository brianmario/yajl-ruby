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
    times_called = 0
    @callback.should_receive(:call).twice do |arg|
      case times_called
      when 0
        arg.should == 'abc'
      when 1
        arg.should == 'def'
      end
      times_called += 1
    end
    @parser.parse '[{"abc": 123},{"def": 456}]'
  end
end