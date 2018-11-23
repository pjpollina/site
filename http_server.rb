# Class for the HTTP server
# Handles all HTTP needs

require 'socket'
require 'time'
require 'uri'
require 'json'
require './http_socket.rb'

class HTTPServer
  WEB_ROOT = './public/'

  MIME_TYPES = {
    'css'  => 'text/css',
    'png'  => 'image/png',
    'jpg'  => 'image/jpeg',
    'ico'  => 'image/x-icon',
    'json' => 'application/json',
    'js'   => 'application/javascript',
    'jsx'  => 'application/javascript'
  }

  def initialize(hostname: 'localhost', port: 4000)
    @tcp = TCPServer.new(hostname, port)
  end

  def serve
    socket = HTTPSocket.new(@tcp.accept)
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

  def self.file_response(raw_filepath, socket)
    filepath = WEB_ROOT + raw_filepath
    if File.exist?(filepath) && !File.directory?(filepath)
      type = MIME_TYPES[filepath[-3..-1]] || 'application/octet-stream'
      File.open(filepath, 'rb') do |file|
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

  def self.redirect(location='/')
    <<~HEREDOC
      HTTP/1.1 303 See Other\r
      Location: #{location}\r
      \r
    HEREDOC
  end

  def self.process_request(socket)
    request = {}
    request[:method], request[:path], request[:client_type] = socket.gets.split(' ')
    request[:body] = []
    while((line = socket.gets) && (line.chomp != ''))
      request[:body] << line
    end
    request
  end

  def self.parse_form_data(form_data, type='form')
    if type == 'form'
      elements = {}
      form_data.split('&').each do |element| 
        key, value = element.split('=', 2)
        elements[key] = URI.decode(value).gsub('+', ' ')
      end
      elements
    elsif type == 'json'
      JSON.parse(form_data)
    end
  end
end