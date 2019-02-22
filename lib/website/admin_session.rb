# All in one admin session class/singleton thing

require 'digest'
require 'securerandom'

module Website
  class AdminSession
    attr_reader :session_id, :client_ip, :expiration

    def initialize(client_ip)
      @session_id = Digest::SHA256.hexdigest "#{Time.now}#{SecureRandom.hex(16)}#{client_ip}"
      @client_ip = client_ip
      @expiration = Time.now + (60 * 60 * 24 * 7)
    end

    def expired?
      Time.now > @expiration
    end

    class << self
      @session = nil

      def set(client_ip)
        @session = AdminSession.new(client_ip)
      end

      def validate(session_id, client_ip)
        return false if(@session.nil? || @session.expired?)
        (session_id == @session.session_id) && (client_ip == @session.client_ip)
      end

      def cookie
        "session_id=#{@session.session_id}; Expires=#{@session.expiration.httpdate}; HttpOnly"
      end

      def unset
        @session = nil
      end
    end
  end
end
