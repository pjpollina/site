# All in one admin session class/singleton thing

require 'digest'
require 'securerandom'

module Website
  $admin_session = nil

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

    def self.set(client_ip)
      $admin_session = AdminSession.new(client_ip)
    end

    def self.validate(session_id, client_ip)
      return false if($admin_session.nil? || $admin_session.expired?)
      (session_id == $admin_session.session_id) && (client_ip == $admin_session.client_ip)
    end
  end
end
