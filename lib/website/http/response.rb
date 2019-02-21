# Helper module for generating HTTP responses

require 'time'
require 'openssl'
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
  
      def static_html(raw_filepath, admin)
        filepath = Website.web_file(raw_filepath)
        if File.exist?(filepath) && !File.directory?(filepath)
          return html_response(File.read(filepath))
        else
          return Blog::Renderer.render_404(admin)
        end
      end
  
      def file_response(raw_filepath, socket, admin)
        filepath = Website.web_file(raw_filepath)
        if File.exist?(filepath) && !File.directory?(filepath)
          type = HTTP::MIME_TYPES[filepath[-3..-1]] || 'application/octet-stream'
          File.open(filepath, 'rb') do |file|
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
          socket.print Blog::Renderer.render_404(admin)
        end
      end
  
      def redirect(location='/')
        <<~HEREDOC
          HTTP/1.1 303 See Other\r
          Location: #{location}\r
          \r
        HEREDOC
      end

      def login_admin(client_ip, redirect='/')
        AdminSession.set(client_ip)
        <<~HEREDOC
          HTTP/1.1 200 OK\r
          Set-Cookie: #{AdminSession.cookie}\r
          \r
          #{redirect}
        HEREDOC
      end
  
      def logout_admin
        mesg = 'Logout successful'
        <<~HEREDOC
          HTTP/1.1 200 OK\r
          Content-Type: text/html
          Content-Length: #{mesg.bytesize}
          Set-Cookie: session_id=; Expires=#{Time.now.httpdate}; HttpOnly\r
          \r
          #{mesg}
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
