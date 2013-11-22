require 'spec_helper'
require 'open3'

describe 'Parsing very long text' do
  shared_examples 'running script successfully' do |script|
    it 'runs successfully' do
      out, err, status = Open3.capture3('ruby', stdin_data: script)
      [err, status.exitstatus].should eq(['', 0])
    end
  end

  context 'when parseing big floats' do
    include_examples('running script successfully', <<-EOS)
require "yajl"
Yajl::Parser.parse('[0.' + '1' * 2**23 + ']')
    EOS
  end

  context 'when parseing long hash key with symbolize_keys option' do
    include_examples('running script successfully', <<-EOS)
require "yajl"
Yajl::Parser.parse('{"' + 'a' * 2**23 + '": 0}', symbolize_keys: true)
    EOS
  end
end
