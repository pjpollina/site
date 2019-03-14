# Helper module for functions that don't fit in anywhere else

module Website
  module Utils
    extend self

    WEB_ROOT = File.expand_path(File.dirname(__FILE__)).gsub('lib/website', 'public/')

    def web_file(path)
      WEB_ROOT + path
    end

    def parse_form_data(form_data)
      elements = {}
      form_data.split('&').each do |element| 
        key, value = element.split('=', 2)
        elements[key.to_sym] = URI.decode(value).gsub('+', ' ')
      end
      return elements
    end

    def full_uri
      path = 'https://' <<  Website.config_info[:host_name]
      unless([443, 80].include?(Website.config_info[:port]))
        path << ":#{Website.config_info[:port]}"
      end
      return path
    end

    def parse_query(path)
      parse_form_data(path.split("?")[1])
    end
  end
end
