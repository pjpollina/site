module Website
  module Blog
    class Blacklist
      def initialize(filename=".blacklist")
        @blacklist = Website.data_file(filename)
        @ip_login_attempts = Hash.new(0)
        load_blacklist
      end

      def banned?(ip)
        @ip_login_attempts[ip] >= 3
      end

      def add_attempt(ip)
        @ip_login_attempts[ip] += 1
      end

      def clear_attempts(ip)
        @ip_login_attempts[ip] = 0
      end

      def blacklist_ip(ip)
        File.open(@blacklist, "a") do |file|
          file.puts(ip)
        end
      end

      private

      def load_blacklist
        if(File.exist?(@blacklist) && !File.directory?(@blacklist))
          File.open(@blacklist) do |file|
            file.each { |ip| @ip_login_attempts[ip.chomp] = 3 }
          end
        end
      end
    end
  end
end