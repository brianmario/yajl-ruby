# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe "Yajl JSON encoder" do
  FILES = Dir[File.dirname(__FILE__)+'/../../benchmark/subjects/*.json']
  
  FILES.each do |file|
    it "should encode #{File.basename(file)}" do
      # we don't care about testing the stream subject as it has multiple JSON strings in it
      if File.basename(file) != 'twitter_stream.json'
        input = File.new(File.expand_path(file), 'r')
        io = StringIO.new
        parser = Yajl::Parser.new
        encoder = Yajl::Encoder.new
      
        hash = parser.parse(input)
        output = encoder.encode(hash, io)
        io.rewind
        hash2 = parser.parse(io)
      
        io.close
        input.close
      
        hash.should == hash2
      end
    end
  end
  
  it "should encode with :pretty turned on and a single space indent" do
    output = "{\n \"foo\": {\n  \"name\": \"bar\",\n  \"id\": 1234\n }\n}\n"
    if RUBY_VERSION.include?('1.9') # FIXME
      output = "{\n \"foo\": {\n  \"id\": 1234,\n  \"name\": \"bar\"\n }\n}\n"
    end
    obj = {:foo => {:id => 1234, :name => "bar"}}
    io = StringIO.new
    encoder = Yajl::Encoder.new(:pretty => true, :indent => ' ')
    encoder.encode(obj, io)
    io.rewind
    io.read.should == output
  end
  
  it "should encode with :pretty turned on and a tab character indent" do
    output = "{\n\t\"foo\": {\n\t\t\"name\": \"bar\",\n\t\t\"id\": 1234\n\t}\n}\n"
    if RUBY_VERSION.include?('1.9') # FIXME
      output = "{\n\t\"foo\": {\n\t\t\"id\": 1234,\n\t\t\"name\": \"bar\"\n\t}\n}\n"
    end
    obj = {:foo => {:id => 1234, :name => "bar"}}
    io = StringIO.new
    encoder = Yajl::Encoder.new(:pretty => true, :indent => "\t")
    encoder.encode(obj, io)
    io.rewind
    io.read.should == output
  end
  
  it "should encode with it's class method with :pretty and a tab character indent options set" do
    output = "{\n\t\"foo\": {\n\t\t\"name\": \"bar\",\n\t\t\"id\": 1234\n\t}\n}\n"
    if RUBY_VERSION.include?('1.9') # FIXME
      output = "{\n\t\"foo\": {\n\t\t\"id\": 1234,\n\t\t\"name\": \"bar\"\n\t}\n}\n"
    end
    obj = {:foo => {:id => 1234, :name => "bar"}}
    io = StringIO.new
    Yajl::Encoder.encode(obj, io, :pretty => true, :indent => "\t")
    io.rewind
    io.read.should == output
  end
  
  it "should encode multiple objects into a single stream" do
    io = StringIO.new
    obj = {:foo => "bar", :baz => 1234}
    encoder = Yajl::Encoder.new
    5.times do
      encoder.encode(obj, io)
    end
    io.rewind
    output = "{\"baz\":1234,\"foo\":\"bar\"}\n{\"baz\":1234,\"foo\":\"bar\"}\n{\"baz\":1234,\"foo\":\"bar\"}\n{\"baz\":1234,\"foo\":\"bar\"}\n{\"baz\":1234,\"foo\":\"bar\"}\n"
    if RUBY_VERSION.include?('1.9') # FIXME
      output = "{\"foo\":\"bar\",\"baz\":1234}\n{\"foo\":\"bar\",\"baz\":1234}\n{\"foo\":\"bar\",\"baz\":1234}\n{\"foo\":\"bar\",\"baz\":1234}\n{\"foo\":\"bar\",\"baz\":1234}\n"
    end
    io.read.should == output
  end
end