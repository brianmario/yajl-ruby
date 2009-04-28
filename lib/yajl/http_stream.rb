require 'socket' unless defined?(Socket)
require 'zlib' unless defined?(Zlib)
require 'yajl' unless defined?(Yajl)

module Yajl
  class HttpStream
    class InvalidContentType < Exception; end

    MIME_TYPE = "application/json"
    
    def self.get(uri)
      socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
      sockaddr = Socket.pack_sockaddr_in(uri.port, uri.host)
      socket.connect(sockaddr)
      socket.write("GET #{uri.path}?#{uri.query} HTTP/1.0\r\nAccept-encoding: gzip,deflate\r\n\r\n")
      
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
      
      if response_head[:headers]["Content-Type"].include?(MIME_TYPE)
        case response_head[:headers]["Content-Encoding"]
        when "gzip"
          socket = Zlib::GzipReader.new(socket)
        end
        return Yajl::Native.parse(socket)
      else
        raise InvalidContentType, "The response MIME type #{response_head[:headers]["Content-Type"]}"
      end
    ensure
      socket.close
    end
  end
end