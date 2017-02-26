require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe "file projection" do
  it "projects file streams" do
    schema = {
      "forced" => nil,
      "created" => nil,
      "pusher" => {
        "name" => nil,
      },
      "repository" => {
        "name" => nil,
        "full_name" => nil,
      },
      "ref" => nil,
      "compare" => nil,
      "commits" => {
        "discinct" => nil,
        "message" => nil,
        "url" => nil,
        "id" => nil,
        "author" => {
          "username" => nil,
        }
      }
    }

    file_path = ENV['JSON_FILE']
    if file_path.nil? || file_path.empty?
      return
    end

    file = File.open(file_path, 'r')
    begin
      puts Yajl::Projector.new(file).project(schema)
    ensure
      file.close
    end
  end
end
