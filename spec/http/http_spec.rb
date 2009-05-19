# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')
require 'yajl/bzip2'
require 'yajl/gzip'
require 'yajl/deflate'
require 'yajl/http_stream'

def parse_off_headers(io)
  io.each_line do |line|
    if line == "\r\n" # end of the headers
      break
    end
  end
end

describe "Yajl HTTP GET request" do
  before(:all) do
    @raw = File.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/http.raw.dump'), 'r')
    @bzip2 = File.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/http.bzip2.dump'), 'r')
    @deflate = File.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/http.deflate.dump'), 'r')
    @gzip = File.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/http.gzip.dump'), 'r')
    
    parse_off_headers(@raw)
    @raw_template_hash = Yajl::Stream.parse(@raw)
    @raw.rewind
  end
  
  after(:all) do
    @raw.close unless @raw.closed?
    @bzip2.close unless @bzip2.closed?
    @deflate.close unless @deflate.closed?
    @gzip.close unless @gzip.closed?
  end
  
  after(:each) do
    GC.start
  end
  
  it "should parse a raw response" do
    file = File.expand_path(File.dirname(__FILE__) + '/http/http.raw.dump')
    uri = 'file://'+file
    
    TCPSocket.should_receive(:new).and_return(@raw)
    @raw.should_receive(:write)
    uri.should_receive(:host).at_least(2).times
    uri.should_receive(:port)
    uri.should_receive(:path)
    uri.should_receive(:query)
    uri.should_receive(:userinfo)
    
    @raw_template_hash.should == Yajl::HttpStream.get(uri)
  end
  
  it "should parse a bzip2 compressed response" do
    file = File.expand_path(File.dirname(__FILE__) + '/http/http.bzip2.dump')
    uri = 'file://'+file
    
    TCPSocket.should_receive(:new).and_return(@bzip2)
    @bzip2.should_receive(:write)
    uri.should_receive(:host).at_least(2).times
    uri.should_receive(:port)
    uri.should_receive(:path)
    uri.should_receive(:query)
    uri.should_receive(:userinfo)
    
    @raw_template_hash.should == Yajl::HttpStream.get(uri)
  end
  
  it "should parse a deflate compressed response" do
    file = File.expand_path(File.dirname(__FILE__) + '/http/http.deflate.dump')
    uri = 'file://'+file
    
    TCPSocket.should_receive(:new).and_return(@deflate)
    @deflate.should_receive(:write)
    uri.should_receive(:host).at_least(2).times
    uri.should_receive(:port)
    uri.should_receive(:path)
    uri.should_receive(:query)
    uri.should_receive(:userinfo)
    
    @raw_template_hash.should == Yajl::HttpStream.get(uri)
  end
  
  it "should parse a gzip compressed response" do
    file = File.expand_path(File.dirname(__FILE__) + '/http/http.gzip.dump')
    uri = 'file://'+file
    
    TCPSocket.should_receive(:new).and_return(@gzip)
    @gzip.should_receive(:write)
    uri.should_receive(:host).at_least(2).times
    uri.should_receive(:port)
    uri.should_receive(:path)
    uri.should_receive(:query)
    uri.should_receive(:userinfo)
    
    @raw_template_hash.should == Yajl::HttpStream.get(uri)
  end
end