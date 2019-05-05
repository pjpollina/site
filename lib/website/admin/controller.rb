# Class that controls administration related things
# Eventually, anyway

require 'website/admin/blacklist'

module Website
  module Admin
    class Controller
      MAX_SESSIONS = 3

      def initialize
        @blacklist = Blacklist.new
        @sessions = []
      end

      def add_session(client_ip)
        session = Session.new(client_ip)
        if(@sessions.count > MAX_SESSIONS)
          @sessions.shift
        end
        @sessions << session
        return session
      end

      def remove_session(session_id, client_ip)
        @sessions.reject! {|session| session.validate(session_id, client_ip) }
      end

      def validate(session_id, client_ip)
        @sessions.any? {|session| session.validate(session_id, client_ip)}
      end

      def post_admin_login(form_data, ip)
        unless(@blacklist.banned?(ip))
          @blacklist.add_attempt(ip)
          password = Utils.parse_form_data(form_data)[:password]
          if(password == ENV['blogapp_author_password'])
            @blacklist.clear_attempts(ip)
            return login_response(add_session(ip))
          elsif(@blacklist.banned?(ip))
            @blacklist.blacklist_ip(ip)
            puts "IP address #{ip} has been blacklisted"
          end
        end
        return HTTP::Response[401, ""]
      end

      def logout(request)
        remove_session(request.cookies[:session_id], request.ip_address)
        return logout_response()
      end

      def login_response(session, redirect='/')
        <<~HEREDOC
          HTTP/1.1 200 OK\r
          Set-Cookie: #{session.cookie}\r
          \r
          #{redirect}
        HEREDOC
      end

      def logout_response(redirect='/')
        <<~HEREDOC
          HTTP/1.1 200 OK\r
          Set-Cookie: session_id=; Expires=#{Time.now.httpdate}; HttpOnly\r
          \r
          <script>alert('Logout successful'); window.location.href='#{redirect}';</script>
        HEREDOC
      end
    end
  end
end
