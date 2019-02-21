# Global website namespace

require 'uri'
require 'yaml'

module Website
  WEB_ROOT = File.expand_path(File.dirname(__FILE__)).gsub('lib', 'public/')

  def self.web_file(path)
    WEB_ROOT + path
  end

  def self.parse_form_data(form_data)
    elements = {}
    form_data.split('&').each do |element| 
      key, value = element.split('=', 2)
      elements[key.to_sym] = URI.decode(value).gsub('+', ' ')
    end
    elements
  end

  $config_info = Hash[YAML.load(File.read(File.expand_path(File.dirname(__FILE__)).gsub('lib', 'data/config.yaml'))).map {|k, v| [k.to_sym, v]}]
end
