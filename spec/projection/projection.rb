require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'stringio'
require 'json'

describe "projection" do
  it "should work" do
    stream = StringIO.new('{"name": "keith", "age": 27}')
    projector = Yajl::Projector.new(stream)
    projection = projector.project({"name" => nil})
    expect(projection['name']).to eql("keith")
  end

  it "should filter" do
    stream = StringIO.new('{"name": "keith", "age": 27}')
    projector = Yajl::Projector.new(stream)
    projection = projector.project({"name" => nil})
    expect(projection['age']).to eql(nil)
  end

  def project(schema, over: "", json: nil, stream: nil)
    if stream.nil?
      if json.nil?
        json = over.to_json
      end

      stream = StringIO.new(json)
    end

    Yajl::Projector.new(stream).project(schema)
  end

  it "filters arrays" do
    json = {
      "users" => [
        {
          "name" => "keith",
          "company" => "internet plumbing inc",
          "department" => "janitorial",
        },
        {
          "name" => "justin",
          "company" => "big blue",
          "department" => "programming?",
        },
        {
          "name" => "alan",
          "company" => "different colour of blue",
          "department" => "drop bear containment",
        }
      ]
    }

    schema = {
      # /users is an array of objects, each having many keys we only want name
      "users" => {
        "name" => nil,
      }
    }

    expect(project(schema, over: json)).to eql({
      "users" => [
        { "name" => "keith" },
        { "name" => "justin" },
        { "name" => "alan" }
      ]
    })
  end

  it "filters top level arrays" do
    json = [
      {
        "name" => "keith",
        "personal detail" => "thing",
      },
      {
        "name" => "cory",
        "phone number" => "unknown",
      }
    ]

    schema = {
      "name" => nil,
    }

    expect(project(schema, over: json)).to eql([
      { "name" => "keith" },
      { "name" => "cory" },
    ])
  end
end