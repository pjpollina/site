# Global website namespace

require 'yaml'

module Website
  extend self

  VERSION = '0.2.1'

  REPO_ROOT = File.expand_path(File.dirname(__FILE__)).chomp("lib")

  def data_file(path)
    Utils.expand_path(REPO_ROOT + "data", path)
  end

  def config_info
    @config_info ||= begin
      hash = Hash.new("")
      path = data_file("config.yml")
      YAML.load_file(path).each do |key, value|
        hash[key.to_sym] = value
      end
      hash
    end
  end
end
