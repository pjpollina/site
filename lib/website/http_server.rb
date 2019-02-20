# Class for the HTTP server
# Handles all HTTP needs

require 'socket'
require 'time'
require 'uri'
require 'openssl'
require 'website/http/request'
require 'website/admin_session'

module Website
  class HTTPServer
    def initialize(hostname: $config_info[:host_name], port: $config_info[:port])
      @tcp = TCPServer.new(hostname, port)
      @ssl = OpenSSL::SSL::SSLServer.new(@tcp, ssl_context)
    end

    def serve(https: false)
      begin
        socket = (https) ? @ssl.accept : @tcp.accept
        request = HTTP::Request[socket]
        yield(socket, request)
        socket.close
      rescue OpenSSL::SSL::SSLError => error
        STDERR.puts("SSL Error: #{error.message}")
      end
    end

    private

    def ssl_context
      ssl_context = OpenSSL::SSL::SSLContext.new
      ssl_context.ssl_version = :SSLv23
      ssl_context.add_certificate(OpenSSL::X509::Certificate.new(File.open(ENV['blogapp_ssl_cert'])), OpenSSL::PKey::RSA.new(File.open(ENV['blogapp_ssl_key'])))
      return ssl_context
    end
  end

  class HTTPServer
    MIME_TYPES = {
      'css'  => 'text/css',
      'png'  => 'image/png',
      'jpg'  => 'image/jpeg',
      'ico'  => 'image/x-icon',
      'json' => 'application/json',
      'js'   => 'application/javascript',
      'jsx'  => 'application/javascript'
    }

    HTTP_STATUSES = {
      200 => 'OK',
      201 => 'Created',
      303 => 'See Other',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      409 => 'Conflict'
    }

    def self.parse_form_data(form_data)
      elements = {}
      form_data.split('&').each do |element| 
        key, value = element.split('=', 2)
        elements[key.to_sym] = URI.decode(value).gsub('+', ' ')
      end
      elements
    end
  end
end
