# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe "Partial parser" do
  before(:each) do
    @parser = Yajl::Parser.new
  end

  it "should stream objects as soon as they are ready" do
    toys = []
    toy_ready = lambda do |item, level|
      toys.push(item["id"]) if level == 2
    end
    key_scanner = lambda do |key, level|
      if level == 1 && key == "rows"
        @parser.on_hash_key = nil
        @parser.on_hash_end = toy_ready
      end
    end
    @parser.on_hash_key = key_scanner

    @parser << '{'
    @parser << '  "total_rows": 4,'
    @parser << '  "rows": ['
    @parser << '    {"id": "buzz" },'
    @parser << '    {"id": "rex" },'
    @parser << '    {"id": "bo" },'
    @parser << '    {"id": "hamm" }'
    @parser << '  ]'
    @parser << '}'

    toys.should eql(%w(buzz rex bo hamm))
  end
end
