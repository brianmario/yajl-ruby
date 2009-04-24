# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe "One-off JSON examples" do
  it "should parse 23456789012E666 and return Infinity" do
    infinity = (1.0/0)
    silence_warnings do
      Yajl::Native.parse(StringIO.new('{"key": 23456789012E666}')).should == {"key" => infinity}
    end
  end
end