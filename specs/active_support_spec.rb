# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe "ActiveSupport test cases" do
  before(:all) do
    @tests = {
      %q({"returnTo":{"\/categories":"\/"}})        => {"returnTo" => {"/categories" => "/"}},
      %q({"return\\"To\\":":{"\/categories":"\/"}}) => {"return\"To\":" => {"/categories" => "/"}},
      %q({"returnTo":{"\/categories":1}})          => {"returnTo" => {"/categories" => 1}},
      %({"returnTo":[1,"a"]})                    => {"returnTo" => [1, "a"]},
      %({"returnTo":[1,"\\"a\\",", "b"]})        => {"returnTo" => [1, "\"a\",", "b"]},
      %({"a": "'", "b": "5,000"})                  => {"a" => "'", "b" => "5,000"},
      %({"a": "a's, b's and c's", "b": "5,000"})   => {"a" => "a's, b's and c's", "b" => "5,000"},
      # multibyte
      %({"matzue": "松江", "asakusa": "浅草"}) => {"matzue" => "松江", "asakusa" => "浅草"},
      %({"a": "2007-01-01"})                       => {'a' => "2007-01-01"}, 
      %({"a": "2007-01-01 01:12:34 Z"})            => {'a' => "2007-01-01 01:12:34 Z"}, 
      # no time zone
      %({"a": "2007-01-01 01:12:34"})              => {'a' => "2007-01-01 01:12:34"}, 
      # needs to be *exact*
      %({"a": " 2007-01-01 01:12:34 Z "})          => {'a' => " 2007-01-01 01:12:34 Z "},
      %({"a": "2007-01-01 : it's your birthday"})  => {'a' => "2007-01-01 : it's your birthday"},
      %([])    => [],
      %({})    => {},
      %({"a":1})     => {"a" => 1},
      %({"a": ""})    => {"a" => ""},
      %({"a":"\\""}) => {"a" => "\""},
      %({"a": null})  => {"a" => nil},
      %({"a": true})  => {"a" => true},
      %({"a": false}) => {"a" => false},
      %q({"a": "http:\/\/test.host\/posts\/1"}) => {"a" => "http://test.host/posts/1"},
      %q({"a": "\u003cunicode\u0020escape\u003e"}) => {"a" => "<unicode escape>"},
      %q({"a": "\\\\u0020skip double backslashes"}) => {"a" => "\\u0020skip double backslashes"},
      %q({"a": "\u003cbr /\u003e"}) => {'a' => "<br />"},
      %q({"b":["\u003ci\u003e","\u003cb\u003e","\u003cu\u003e"]}) => {'b' => ["<i>","<b>","<u>"]}
    }
    @bad = "{: 1}"
  end
  
  it "should be able to parse all examples" do
    @tests.each do |json, expected|
      lambda {
        Yajl::Native.parse(StringIO.new(json)).should eql(expected)
      }.should_not raise_error(Yajl::ParseError)
    end
  end
  
  it "should fail parsing #{@bad}" do
    lambda {
      Yajl::Native.parse(StringIO.new(@bad))
    }.should raise_error(Yajl::ParseError)
  end
end
