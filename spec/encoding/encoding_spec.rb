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
end