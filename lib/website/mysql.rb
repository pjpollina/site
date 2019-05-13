# Functional programming-centric interface for MySQL database

require 'mysql2'

module Website
  class MySQL
    def initialize(username, password, database)
      @username = username
      @password = password
      @database = database
    end

    def connect
      client = new_client
      yield(client)
      client.close
    end

    private

    def new_client
      Mysql2::Client.new(username: @username, password: @password, database: @database)
    end
  end
end
