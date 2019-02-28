# Class for the HTTP server
# Handles all HTTP needs

require 'socket'
require 'openssl'

module Website
  module HTTP
    class Server
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

      def accept(https)
        begin
          return (https) ? @ssl.accept : @tcp.accept
        rescue OpenSSL::SSL::SSLError => error
          STDERR.puts("SSL Error: #{error.message}")
          return nil
        end
      end

      def ssl_context
        ssl_context = OpenSSL::SSL::SSLContext.new
        ssl_context.ssl_version = :SSLv23
        ssl_context.add_certificate(OpenSSL::X509::Certificate.new(File.open(ENV['blogapp_ssl_cert'])), OpenSSL::PKey::RSA.new(File.open(ENV['blogapp_ssl_key'])))
        return ssl_context
      end
    end
  end
end
