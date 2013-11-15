require 'spec_helper'
require 'open3'

describe 'Parsing numbers with long representations' do
  # FIXME: a better description
  it 'parses big integer' do
    out, err, status = Open3.capture3('ruby', stdin_data: <<-EOS)
require "yajl"

Yajl::Parser.parse('[' + '1' * 2**23 + ']')
    EOS
    status.exitstatus.should eq(0)
    err.should eq('')
  end

  it 'parses big float' do
    out, err, status = Open3.capture3('ruby', stdin_data: <<-EOS)
require "yajl"

Yajl::Parser.parse('[0.' + '1' * 2**23 + ']')
    EOS
    status.exitstatus.should eq(0)
    err.should eq('')
  end
end
