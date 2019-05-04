# All in one admin session class/singleton thing

require 'time'
require 'digest'
require 'securerandom'

module Website
  module Admin
    class Session
      attr_reader :session_id, :client_ip, :expiration

      def initialize(client_ip)
        @session_id = Digest::SHA256.hexdigest "#{Time.now}#{SecureRandom.hex(16)}#{client_ip}"
        @client_ip = client_ip
        @expiration = Time.now + (60 * 60 * 24 * 7)
      end

      def expired?
        Time.now > @expiration
      end

      def validate(session_id, client_ip)
        (!expired?) && (session_id == @session_id) && (client_ip == @client_ip)
      end

      def cookie
        "session_id=#{@session_id}; Expires=#{@expiration.httpdate}; HttpOnly"
      end

      class << self
        @session = nil

        def set(client_ip)
          @session = new(client_ip)
        end

        def validate(session_id, client_ip)
          return false if(@session.nil? || @session.expired?)
          (session_id == @session.session_id) && (client_ip == @session.client_ip)
        end

        def cookie
          "session_id=#{@session.session_id}; Expires=#{@session.expiration.httpdate}; HttpOnly"
        end

        def login_request(client_ip, redirect='/')
          Session.set(client_ip)
          <<~HEREDOC
            HTTP/1.1 200 OK\r
            Set-Cookie: #{Session.cookie}\r
            \r
            #{redirect}
          HEREDOC
        end

        def logout_request
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

        def unset
          @session = nil
        end

        private :new
      end
    end
  end
end
