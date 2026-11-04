require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')
require 'yajl/deflate'

describe Yajl::Deflate::StreamReader do
  describe ".parse" do
    let(:json) { '{"a":1}' }
    let(:zlib_stream) { Zlib::Deflate.deflate(json) }

    # A raw deflate stream has no zlib header, so it only inflates when the
    # window bits given to .parse actually reach Zlib::Inflate.
    let(:raw_stream) do
      deflate = Zlib::Deflate.new(Zlib::DEFAULT_COMPRESSION, -Zlib::MAX_WBITS)
      begin
        deflate.deflate(json, Zlib::FINISH)
      ensure
        deflate.close
      end
    end

    context "with a String input and an Integer options argument" do
      it "inflates and parses the input" do
        expect(described_class.parse(zlib_stream, Zlib::MAX_WBITS)).to eq("a" => 1)
      end

      it "passes the Integer through to Zlib::Inflate as the window bits" do
        expect(described_class.parse(raw_stream, -Zlib::MAX_WBITS)).to eq("a" => 1)
      end
    end

    context "with a String input and a Hash options argument" do
      it "passes :deflate_options through to Zlib::Inflate as the window bits" do
        expect(described_class.parse(raw_stream, :deflate_options => -Zlib::MAX_WBITS)).to eq("a" => 1)
      end

      it "passes the remaining options through to the parser" do
        options = { :deflate_options => -Zlib::MAX_WBITS, :symbolize_keys => true }

        expect(described_class.parse(raw_stream, options)).to eq(:a => 1)
      end
    end
  end
end
