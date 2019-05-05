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

      def post_admin_login(form_data, ip)
        unless(@blacklist.banned?(ip))
          @blacklist.add_attempt(ip)
          password = Utils.parse_form_data(form_data)[:password]
          if(password == ENV['blogapp_author_password'])
            @blacklist.clear_attempts(ip)
            return Admin::Session.login_request(ip)
          elsif(@blacklist.banned?(ip))
            @blacklist.blacklist_ip(ip)
            puts "IP address #{ip} has been blacklisted"
          end
        end
        return HTTP::Response[401, ""]
      end

      def login_response(session, redirect='/')
        <<~HEREDOC
          HTTP/1.1 200 OK\r
          Set-Cookie: #{session.cookie}\r
          \r
          #{redirect}
        HEREDOC
      end
    end
  end
end
