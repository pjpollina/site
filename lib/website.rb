# Global website namespace

require 'yaml'

module Website
  extend self

  def config_info
    @config_info ||= begin
      hash = Hash.new("")
      path = File.expand_path(File.dirname(__FILE__)).gsub('lib', 'data/config.yml')
      YAML.load_file(path).each do |key, value|
        hash[key.to_sym] = value
      end
      hash
    end
  end
end
