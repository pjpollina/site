# Global website namespace

require 'yaml'

module Website
  WEB_ROOT = File.expand_path(File.dirname(__FILE__)).gsub('lib/website', 'public/')

  def self.web_file(path)
    WEB_ROOT + path
  end

  $config_info = Hash[YAML.load(File.read(File.expand_path(File.dirname(__FILE__)).gsub('lib', 'data/config.yaml'))).map {|k, v| [k.to_sym, v]}]
end
