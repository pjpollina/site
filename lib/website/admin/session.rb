# Class representing an active admin session

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
    end
  end
end
