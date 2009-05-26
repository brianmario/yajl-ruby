# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe "One-off JSON examples" do
  it "should parse 23456789012E666 and return Infinity" do
    infinity = (1.0/0)
    silence_warnings do
      parser = Yajl::Parser.new
      parser.parse(StringIO.new('{"key": 23456789012E666}')).should == {"key" => infinity}
    end
  end
  
  it "should not parse JSON with a comment, with :allow_comments set to false" do
    parser = Yajl::Parser.new(:allow_comments => false)
    json = StringIO.new('{"key": /* this is a comment */ "value"}')
    lambda {
      parser.parse(json)
    }.should raise_error(Yajl::ParseError)
  end
  
  it "should parse JSON with a comment, with :allow_comments set to true" do
    parser = Yajl::Parser.new(:allow_comments => true)
    json = StringIO.new('{"key": /* this is a comment */ "value"}')
    lambda {
      parser.parse(json)
    }.should_not raise_error(Yajl::ParseError)
  end
  
  it "should not parse invalid UTF8 with :check_utf8 set to true" do
    pending
    # not sure how to write this test yet
  end
  
  it "should parse invalid UTF8 with :check_utf8 set to false" do
    pending
    # not sure how to write this test yet
  end
  
  it "should parse using it's class method" do
    io = StringIO.new('{"key": 1234}')
    Yajl::Parser.parse(io).should == {"key", 1234}
  end
end