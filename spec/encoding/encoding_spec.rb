# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe "Yajl JSON encoder" do
  FILES = Dir[File.dirname(__FILE__)+'/../../benchmark/subjects/*.json']
  
  FILES.each do |file|
    it "should encode #{File.basename(file)}" do
      input = File.new(File.expand_path(file), 'r')
      hash = Yajl::Stream.parse(input)
      
      io = StringIO.new
      output = Yajl::Stream.encode(hash, io)
      io.rewind
      hash2 = Yajl::Stream.parse(io)
      
      io.close
      input.close
      
      hash.should == hash2
    end
  end
end