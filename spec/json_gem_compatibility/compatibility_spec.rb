# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

class Dummy; end

describe "JSON Gem compatability API" do
  it "shoud not mixin #to_json on base objects until compatability has been enabled" do
    d = Dummy.new
    
    d.respond_to?(:to_json).should_not be_true
    "".respond_to?(:to_json).should_not be_true
    1.respond_to?(:to_json).should_not be_true
    "1.5".to_f.respond_to?(:to_json).should_not be_true
    [].respond_to?(:to_json).should_not be_true
    {:foo => "bar"}.respond_to?(:to_json).should_not be_true
    true.respond_to?(:to_json).should_not be_true
    false.respond_to?(:to_json).should_not be_true
    nil.respond_to?(:to_json).should_not be_true
  end
  
  it "should mixin #to_json on base objects after compatability has been enabled" do
    Yajl::Encoder.enable_json_gem_compatability
    d = Dummy.new
    
    d.respond_to?(:to_json).should be_true
    "".respond_to?(:to_json).should be_true
    1.respond_to?(:to_json).should be_true
    "1.5".to_f.respond_to?(:to_json).should be_true
    [].respond_to?(:to_json).should be_true
    {:foo => "bar"}.respond_to?(:to_json).should be_true
    true.respond_to?(:to_json).should be_true
    false.respond_to?(:to_json).should be_true
    nil.respond_to?(:to_json).should be_true
  end
  
  it "should require yajl/json_gem to enable the compatability API" do
    require 'yajl/json_gem'
    
    defined?(JSON).should be_true
    
    JSON.respond_to?(:parse).should be_true
    JSON.respond_to?(:generate).should be_true
    JSON.respond_to?(:pretty_generate).should be_true
    JSON.respond_to?(:load).should be_true
    JSON.respond_to?(:dump).should be_true
  end
  
  context "ported tests for Unicode" do
    it "should be able to encode and parse unicode" do
      '""'.should eql(''.to_json)
      '"\\b"'.should eql("\b".to_json)
      '"\u0001"'.should eql(0x1.chr.to_json)
      '"\u001F"'.should eql(0x1f.chr.to_json)
      '" "'.should eql(' '.to_json)
      "\"#{0x7f.chr}\"".should eql(0x7f.chr.to_json)
      utf8 = [ "© ≠ €! \01" ]
      json = '["© ≠ €! \u0001"]'
      json.should eql(utf8.to_json)
      utf8.should eql(JSON.parse(json))
      utf8 = ["\343\201\202\343\201\204\343\201\206\343\201\210\343\201\212"]
      json = "[\"あいうえお\"]"
      json.should eql(utf8.to_json)
      utf8.should eql(JSON.parse(json))
      utf8 = ['საქართველო']
      json = "[\"საქართველო\"]"
      json.should eql(utf8.to_json)
      utf8.should eql(JSON.parse(json))
      '["Ã"]'.should eql(JSON.generate(["Ã"]))
      ["€"].should eql(JSON.parse('["\u20ac"]'))
      utf8_str = "\xf0\xa0\x80\x81"
      utf8 = [utf8_str]
      json = "[\"#{utf8_str}\"]"
      json.should eql(JSON.generate(utf8))
      utf8.should eql(JSON.parse(json))
    end
  end
  
  context "ported tests for generation" do
    before(:all) do
      @hash = {
        'a' => 2,
        'b' => 3.141,
        'c' => 'c',
        'd' => [ 1, "b", 3.14 ],
        'e' => { 'foo' => 'bar' },
        'g' => "\"\037",
        'h' => 1000.0,
        'i' => 0.001
      }
      
      @json2 = '{"a":2,"b":3.141,"c":"c","d":[1,"b",3.14],"e":{"foo":"bar"},"g":"\\"\\u001f","h":1000.0,"i":0.001}'
      
      @json3 = '{
          "a": 2,
          "b": 3.141,
          "c": "c",
          "d": [1, "b", 3.14],
          "e": {"foo": "bar"},
          "g": "\"\u001f",
          "h": 1000.0,
          "i": 0.001}'
    end
    
    it "should be able to unparse" do
      json = JSON.generate(@hash)
      JSON.parse(@json2).should == JSON.parse(json)
      parsed_json = JSON.parse(json)
      @hash.should == parsed_json
      json = JSON.generate({1=>2})
      '{"1":2}'.should eql(json)
      parsed_json = JSON.parse(json)
      {"1"=>2}.should == parsed_json
    end
  end
end
