# Class for the HTTP server
# Handles all HTTP needs

require 'socket'
require 'time'

class HTTPServer
  def initialize(hostname: 'localhost', port: 4000)
    @tcp = TCPServer.new(hostname, port)
  end

  def serve
    socket = @tcp.accept
    yield(socket)
    socket.close
  end

  def self.generic_html(response_html)
    <<~HEREDOC
      HTTP/1.1 200 OK\r
      Content-Type: text/html\r
      Content-Length: #{response_html.bytesize}\r
      Date: #{Time.now.httpdate}\r
      Connection: close\r
      \r
      #{response_html}
    HEREDOC
  end

  def self.generic_404
    mesg = '<title>404 Error</title><h1>404 Not Found</h1>'
    <<~HEREDOC
      HTTP/1.1 404 Not Found\r
      Content-Type: text/html\r
      Content-Length: #{mesg.bytesize}\r
      Date: #{Time.now.httpdate}\r
      Connection: close\r
      \r
      #{mesg}
    HEREDOC
  end

  IMAGE_TYPES = {
    'png' => 'image/png',
    'jpg' => 'image/jpeg',
    'ico' => 'image/x-icon'
  }

  def self.image_response(image_path, socket)
    if File.exist?(image_path) && !File.directory?(image_path)
      type = IMAGE_TYPES(image_path[-3..-1]) || 'application/octet-stream'
      File.open(image_path, 'rb') do |file|
        socket.print <<~HEREDOC
          HTTP/1.1 200 OK\r
          Content-Type: #{type}\r
          Content-Length: #{file.size}\r
          Date: #{Time.now.httpdate}\r
          Connection: close\r
          \r
        HEREDOC
        IO.copy_stream(file, socket)
      end
    else
      socket.print generic_404
    end
end