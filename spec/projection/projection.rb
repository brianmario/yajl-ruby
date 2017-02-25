require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'stringio'

describe "projection" do
  it "should work" do
    stream = StringIO.new('{"name": "keith", "age": 27}')
    projector = Yajl::Projector.new(stream)
    projection = projector.project({"name" => nil})
    expect(projection['name']).to eql("keith")
  end
end