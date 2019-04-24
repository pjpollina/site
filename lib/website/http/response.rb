# Helper module for generating HTTP responses

require 'time'
require 'openssl'
require 'website/web_file'
require 'website/admin_session'

module Website
  module HTTP
    module Response
      extend self

      def status_line(status_code)
        'HTTP/1.1 ' << status_code << ' ' << HTTP::STATUSES[status_code]
      end

      def response(status_code, body, headers={})
        response = status_line(status_code) << "\r\n"
        headers.each do |name, value|
          response << "#{name}: #{value}\r\n"
        end
        response << "\r\n#{body}"
      end

      alias_method(:[], :response)

      def html_response(html, status_code=200)
        <<~RESPONSE
          #{status_line(status_code)}\r
          Content-Type: text/html\r
          Content-Length: #{html.bytesize}\r
          Date: #{Time.now.httpdate}\r
          Connection: close\r
          \r
          #{html}
        RESPONSE
      end

      def static_html(path, admin)
        if WebFile.exists?(path)
          return html_response(WebFile.read(path))
        else
          return Blog::Renderer.render_error_page(404, admin)
        end
      end

      def file_response(path, socket, admin)
        if WebFile.exists?(path)
          type = HTTP::MIME_TYPES[path.split('.')[-1]] || 'application/octet-stream'
          WebFile.open(path, 'rb') do |file|
            socket.print <<~HEREDOC
              HTTP/1.1 200 OK\r
              Content-Type: #{type}\r
              Content-Length: #{file.size}\r
              Date: #{Time.now.httpdate}\r
              Cache-Control: max-age=#{cache_time(type)}\r
              Etag: "#{OpenSSL::Digest::MD5.digest(file.to_s)}"\r
              Connection: close\r
              \r
            HEREDOC
            IO.copy_stream(file, socket)
          end
        else
          socket.print Blog::Renderer.render_error_page(404, admin)
        end
      end

      def redirect(location='/')
        <<~HEREDOC
          HTTP/1.1 303 See Other\r
          Location: #{location}\r
          \r
        HEREDOC
      end

      def cache_time(type)
        case type.split('/')[0]
        when 'image'
          return 60 * 60 * 2
        else
          return 60 * 5
        end
      end
    end
  end
end
