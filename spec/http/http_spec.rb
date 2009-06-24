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
    raw = File.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/http.raw.dump'), 'r')
    parse_off_headers(raw)
    @template_hash = Yajl::Parser.parse(raw)
    
    raw.rewind
    parse_off_headers(raw)
    @template_hash_symbolized = Yajl::Parser.parse(raw, :symbolize_keys => true)
    
    @deflate = File.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/http.deflate.dump'), 'r')
    @gzip = File.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/http.gzip.dump'), 'r')
  end
  
  after(:each) do
    @file_path = nil
  end
  
  def prepare_mock_request_dump(format=:raw)
    @request = File.new(File.expand_path(File.dirname(__FILE__) + "/fixtures/http.#{format}.dump"), 'r')
    @uri = 'file://'+File.expand_path(File.dirname(__FILE__) + "/fixtures/http/http.#{format}.dump")
    TCPSocket.should_receive(:new).and_return(@request)
    @request.should_receive(:write)
    @uri.should_receive(:host).at_least(2).times
    @uri.should_receive(:port)
    @uri.should_receive(:path)
    @uri.should_receive(:query)
    @uri.should_receive(:userinfo)
  end
  
  it "should parse a raw response" do
    prepare_mock_request_dump :raw
    @template_hash.should == Yajl::HttpStream.get(@uri)
  end
  
  it "should parse a raw response and symbolize keys" do
    prepare_mock_request_dump :raw
    @template_hash_symbolized.should == Yajl::HttpStream.get(@uri, :symbolize_keys => true)
  end
  
  it "should parse a bzip2 compressed response" do
    prepare_mock_request_dump :bzip2
    @template_hash.should == Yajl::HttpStream.get(@uri)
  end
  
  it "should parse a bzip2 compressed response and symbolize keys" do
    prepare_mock_request_dump :bzip2
    @template_hash_symbolized.should == Yajl::HttpStream.get(@uri, :symbolize_keys => true)
  end
  
  it "should parse a deflate compressed response" do
    prepare_mock_request_dump :deflate
    @template_hash.should == Yajl::HttpStream.get(@uri)
  end
  
  it "should parse a deflate compressed response and symbolize keys" do
    prepare_mock_request_dump :deflate
    @template_hash_symbolized.should == Yajl::HttpStream.get(@uri, :symbolize_keys => true)
  end
  
  it "should parse a gzip compressed response" do
    prepare_mock_request_dump :gzip
    @template_hash.should == Yajl::HttpStream.get(@uri)
  end
  
  it "should parse a gzip compressed response and symbolize keys" do
    prepare_mock_request_dump :gzip
    @template_hash_symbolized.should == Yajl::HttpStream.get(@uri, :symbolize_keys => true)
  end
end