describe "Yajl HTTP request" do
  before(:each) do
    @request = File.new(File.expand_path(File.dirname(__FILE__) + "/fixtures/http.raw.dump"), 'r')
    @uri = URI.parse('file://'+File.expand_path(File.dirname(__FILE__) + "/fixtures/http/http.raw.dump"))
    @uri_with_userinfo = @uri.clone
    @uri_with_userinfo.userinfo = 'krekoten:secret'
    TCPSocket.should_receive(:new).and_return(@request)
    class << @request
      def request_data
        @request_data ||= ''
      end
      attr_writer :request_data

      def write(request_str)
        request_data << request_str
      end
    end
  end

  it 'should not include Authorization header if no :auth provided' do
    Yajl::HttpStream.get(@uri)
    @request.request_data.should_not =~ /Authorization:/
  end
  
  it 'should include Basic Authorization if userinfo provedid' do
    Yajl::HttpStream.get(@uri_with_userinfo)
    basic = ["krekoten:secret"].pack('m').strip!
    @request.request_data.should =~ Regexp.new("Authorization: Basic #{Regexp.escape(basic)}")
  end
  
  it 'should include Authorization if it is provided' do
    Yajl::HttpStream.get(@uri, :auth => 'OAuth')
    @request.request_data.should =~ /Authorization: OAuth/
  end
end
