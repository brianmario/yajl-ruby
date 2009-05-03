# encoding: UTF-8
require 'socket' unless defined?(Socket)
require 'yajl.rb' unless defined?(Yajl)

module Yajl
  # == Yajl::HttpStream
  #
  # This module is for making HTTP requests to which the response bodies (and possibly requests in the near future)
  # are streamed directly into Yajl.
  class HttpStream
    # === Yajl::HttpStream::InvalidContentType
    #
    # This Exception is thrown when an HTTP response isn't application/json
    # and therefore cannot be parsed.
    class InvalidContentType < Exception; end
    
    # The mime-type we expect the response to be. If it's anything else, we can't parse it
    # and an InvalidContentType is raised.
    ALLOWED_MIME_TYPES = ["application/json", "text/plain"]
    
    # Makes a basic HTTP GET request to the URI provided
    # 1. a raw socket is opened to the server/host provided
    # 2. the request is made using HTTP/1.0, Accept-encoding: gzip (deflate support coming soon, too)
    # 3. the response is read until the end of the headers
    # 4. the _socket itself_ is passed directly to Yajl, for direct parsing off the stream;
    #    As it's being received over the wire!
    def self.get(uri)
      socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
      sockaddr = Socket.pack_sockaddr_in(uri.port, uri.host)
      socket.connect(sockaddr)
      request = "GET #{uri.path}#{uri.query ? "?"+uri.query : nil} HTTP/1.0\r\n"
      request << "Host: #{uri.host}\r\n"
      request << "Authorization: Basic #{[userinfo].pack('m')}\r\n" unless uri.userinfo.nil?
      request << "User-Agent: Yajl::HttpStream #{Yajl::VERSION}\r\n"
      request << "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"
      request << "Accept-Encoding: gzip\r\n"
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
      
      content_type = response_head[:headers]["Content-Type"].split('; ')
      content_type = content_type[0] if content_type.size > 1
      if ALLOWED_MIME_TYPES.include?(content_type)
        case response_head[:headers]["Content-Encoding"]
        when "gzip"
          socket = Yajl::GzipStreamReader.new(socket)
        end
        return Yajl::Stream.parse(socket)
      else
        raise InvalidContentType, "The response MIME type #{content_type}"
      end
    ensure
      socket.close
    end
  end
end