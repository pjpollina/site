# Class representing an incoming HTTP/1.1 request

require 'website/admin/session'

module Website
  module HTTP
    class Request
      attr_reader :method, :path, :headers, :cookies, :ip_address, :content

      def initialize(socket)
        @method, @path = socket.gets.split(' ')[0..1]
        @headers, @cookies = {}, {}
        while((line = socket.gets.chomp) && (line != ''))
          key, value = line.split(': ', 2)
          if(key == 'Cookie')
            value.split('; ').each do |cookie|
              key, value = cookie.split('=')
              @cookies[keyify(key)] = value
            end
          else
            @headers[keyify(key)] = value
          end
        end
        @ip_address = socket.peeraddr[3]
        if(@headers.keys.include?(:content_length))
          @content = socket.read(@headers[:content_length].to_i)
        else
          @content = ''
        end
      end

      def request_line
        "#{@method} #{@path} HTTP/1.1"
      end

      def admin?
        Admin::Session.validate(@cookies[:session_id], @ip_address)
      end

      def static_html?
        @path.end_with?('.html')
      end

      def file_request?
        @path.end_with?(*HTTP::MIME_TYPES.keys)
      end

      def self.[](socket)
        socket.eof?() ? nil : new(socket)
      end

      private

      def keyify(header)
        header.downcase.gsub('-', '_').to_sym
      end
    end
  end
end
