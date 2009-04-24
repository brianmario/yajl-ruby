# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe "Parsing JSON Fixtures" do
  before(:all) do
    fixtures = File.join(File.dirname(__FILE__), 'fixtures/*.json')
    passed, failed = Dir[fixtures].partition { |f| f['pass'] }
    @passed = passed.inject([]) { |a, f| a << [ f, File.read(f) ] }.sort
    @failed = failed.inject([]) { |a, f| a << [ f, File.read(f) ] }.sort
  end
  
  it "should not be able to parse all fixtures marked as bad" do
    @failed.each do |name, source|
      lambda {
        Yajl::Native.parse(StringIO.new(source))
      }.should raise_error(Yajl::ParseError)
    end
  end
  
  it "should be able to parse all fixtures marked as good" do
    @passed.each do |name, source|
      lambda {
        Yajl::Native.parse(StringIO.new(source))
      }.should_not raise_error(Yajl::ParseError)
    end
  end
end