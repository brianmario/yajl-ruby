# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe "One-off JSON examples" do
  it "should parse 23456789012E666 and return Infinity" do
    infinity = (1.0/0)
    silence_warnings do
      Yajl::Parser.parse(StringIO.new('{"key": 23456789012E666}')).should == {"key" => infinity}
    end
  end
  
  it "should not parse JSON with a comment, with :allow_comments set to false" do
    json = StringIO.new('{"key": /* this is a comment */ "value"}')
    lambda {
      Yajl::Parser.parse(json, :allow_comments => false)
    }.should raise_error(Yajl::ParseError)
  end
  
  it "should parse JSON with a comment, with :allow_comments set to true" do
    json = StringIO.new('{"key": /* this is a comment */ "value"}')
    lambda {
      Yajl::Parser.parse(json, :allow_comments => true)
    }.should_not raise_error(Yajl::ParseError)
  end
  
  it "should not parse invalid UTF8 with :check_utf8 set to true" do
    pending "not sure how to write this test yet"
  end
  
  it "should parse invalid UTF8 with :check_utf8 set to false" do
    pending "not sure how to write this test yet"
  end
  
  it "should parse using it's class method, from an IO" do
    io = StringIO.new('{"key": 1234}')
    Yajl::Parser.parse(io).should == {"key" => 1234}
  end
  
  it "should parse using it's class method, from an IO with symbolized keys" do
    Yajl::Parser.parse('{"key": 1234}', :symbolize_keys => true).should == {:key => 1234}
  end
  
  it "should parse using it's class method, from a string" do
    Yajl::Parser.parse('{"key": 1234}').should == {"key" => 1234}
  end
  
  it "should parse using it's class method, from a string with a block" do
    output = nil
    Yajl::Parser.parse('{"key": 1234}') do |obj|
      output = obj
    end
    output.should == {"key" => 1234}
  end
end