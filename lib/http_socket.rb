# Wrapper class for a TCPSocket to simplify HTTP serving process

require './http_server.rb'

class HTTPSocket
  attr_reader :socket, :request

  def initialize(socket)
    @socket = socket
    @request = HTTPServer.process_request(socket)
  end

  def serve_html(html)
    @socket.print HTTPServer.generic_html(html)
  end

  def serve_404
    @socket.print HTTPServer.generic_404
  end

  def serve_redirect(location='/')
    @socket.print HTTPServer.redirect(location)
  end

  def serve_file(filepath)
    HTTPServer.file_response(filepath, @socket)
  end

  def close
    @socket.close
  end
end