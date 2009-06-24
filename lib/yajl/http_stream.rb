# encoding: UTF-8
require 'socket' unless defined?(Socket)
require 'yajl' unless defined?(Yajl::Parser)

module Yajl
  # This module is for making HTTP requests to which the response bodies (and possibly requests in the near future)
  # are streamed directly into Yajl.
  class HttpStream
    
    # This Exception is thrown when an HTTP response isn't in ALLOWED_MIME_TYPES
    # and therefore cannot be parsed.
    class InvalidContentType < Exception; end
    
    # The mime-type we expect the response to be. If it's anything else, we can't parse it
    # and an InvalidContentType is raised.
    ALLOWED_MIME_TYPES = ["application/json", "text/plain"]
    
    # Makes a basic HTTP GET request to the URI provided
    # 1. a raw socket is opened to the server/host provided
    # 2. the request is made using HTTP/1.0, Accept-encoding: gzip (deflate support coming soon, too)
    # 3. the response is read until the end of the headers
    # 4. the _socket itself_ is passed directly to Yajl, for direct parsing off the stream; As it's being received over the wire!
    def self.get(uri, opts = {}, &block)
      user_agent = opts.has_key?('User-Agent') ? opts.delete(['User-Agent']) : "Yajl::HttpStream #{Yajl::VERSION}"
      
      socket = TCPSocket.new(uri.host, uri.port)
      request = "GET #{uri.path}#{uri.query ? "?"+uri.query : nil} HTTP/1.1\r\n"
      request << "Host: #{uri.host}\r\n"
      request << "Authorization: Basic #{[uri.userinfo].pack('m')}\r\n" unless uri.userinfo.nil?
      request << "User-Agent: #{user_agent}\r\n"
      request << "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"
      request << "Connection: close\r\n"
      encodings = []
      encodings << "bzip2" if defined?(Yajl::Bzip2)
      encodings << "gzip" if defined?(Yajl::Gzip)
      encodings << "deflate" if defined?(Yajl::Deflate)
      request << "Accept-Encoding: #{encodings.join(',')}\r\n" if encodings.any?
      request << "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\n"
      request << "\r\n\r\n"
      socket.write(request)
      response_head = {}
      response_head[:headers] = {}
      
      socket.each_line do |line|
        if line == "\r\n" # end of the headers
          break
        else
          header = line.split(": ")
          if header.size == 1
            header = header[0].split(" ")
            response_head[:version] = header[0]
            response_head[:code] = header[1].to_i
            response_head[:msg] = header[2]
            # this is the response code line
          else
            response_head[:headers][header[0]] = header[1].strip
          end
        end
      end
      parser = Yajl::Parser.new(opts)
      if response_head[:headers]["Transfer-Encoding"] == 'chunked'
        if block_given?
          parser.on_parse_complete = block
          chunkLeft = 0
          while !socket.eof? && (size = socket.gets.hex)
            next if size == 0
            json = socket.read(size)
            chunkLeft = size-json.size
            if chunkLeft == 0
              parser << json
            else
              # received only part of the chunk, grab the rest
              parser << socket.read(chunkLeft)
            end
          end
        else
          raise Exception, "Chunked responses detected, but no block given to handle the chunks."
        end
      else
        content_type = response_head[:headers]["Content-Type"].split(';')
        content_type = content_type.first
        if ALLOWED_MIME_TYPES.include?(content_type)
          case response_head[:headers]["Content-Encoding"]
          when "gzip"
            return Yajl::Gzip::StreamReader.parse(socket, opts)
          when "deflate"
            return Yajl::Deflate::StreamReader.parse(socket, opts.merge({:deflate_options => -Zlib::MAX_WBITS}))
          when "bzip2"
            return Yajl::Bzip2::StreamReader.parse(socket, opts)
          else
            return Yajl::Parser.new(opts).parse(socket)
          end
        else
          raise InvalidContentType, "The response MIME type #{content_type}"
        end
      end
    ensure
      socket.close
    end
  end
end
