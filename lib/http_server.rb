# Class for the HTTP server
# Handles all HTTP needs

require 'socket'
require 'time'
require 'uri'
require 'json'
require 'digest'
require './lib/admin_session.rb'

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
    socket = @tcp.accept
    request = self.class.process_request(socket)
    yield(socket, request)
    socket.close
  end

  def self.html_response(html, status_code=200, status_text='OK')
    <<~RESPONSE
      HTTP/1.1 #{status_code} #{status_text}\r
      Content-Type: text/html\r
      Content-Length: #{html.bytesize}\r
      Date: #{Time.now.httpdate}\r
      Connection: close\r
      \r
      #{html}
    RESPONSE
  end

  def self.static_html(raw_filepath, controller)
    filepath = web_file(raw_filepath)
    if File.exist?(filepath) && !File.directory?(filepath)
      return html_response(File.read(filepath))
    else
      return controller.render_404
    end
  end

  def self.file_response(raw_filepath, socket, controller)
    filepath = web_file(raw_filepath)
    if File.exist?(filepath) && !File.directory?(filepath)
      type = MIME_TYPES[filepath[-3..-1]] || 'application/octet-stream'
      File.open(filepath, 'rb') do |file|
        socket.print <<~HEREDOC
          HTTP/1.1 200 OK\r
          Content-Type: #{type}\r
          Content-Length: #{file.size}\r
          Date: #{Time.now.httpdate}\r
          Cache-Control: max-age=#{cache_time(type)}\r
          Etag: "#{Digest::MD5.digest(file.to_s)}"\r
          Connection: close\r
          \r
        HEREDOC
        IO.copy_stream(file, socket)
      end
    else
      socket.print controller.render_404
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
    return nil if(socket.eof?)
    request = {}
    request[:method], request[:path], request[:client_type] = socket.gets.split(' ')
    request[:headers], request[:cookies] = {}, {}
    while((line = socket.gets) && (line.chomp != ''))
      key, value = line.chomp.split(': ', 2)
      if(key == "Cookie")
        value.split("; ").each do |cookie|
          key, value = cookie.split("=")
          request[:cookies][key] = value
        end
      else
        request[:headers][key] = value
      end
    end
    request[:ip] = socket.peeraddr[3]
    request[:admin] = AdminSession.validate(request[:cookies]['session_id'], request[:ip])
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

  def self.login_admin(client_ip, redirect='/')
    AdminSession.set(client_ip)
    <<~HEREDOC
      HTTP/1.1 200 OK\r
      Set-Cookie: session_id=#{$admin_session.session_id}; Expires=#{$admin_session.expiration.httpdate}; HttpOnly\r
      \r
      #{redirect}
    HEREDOC
  end

  def self.web_file(path)
    WEB_ROOT + path
  end

  def self.cache_time(type)
    case type.split('/')[0]
    when 'image'
      return 60 * 60 * 2
    else
      return 60 * 5
    end
  end
end