# Global website namespace

require 'yaml'

module Website
  $config_info = Hash[YAML.load(File.read(File.expand_path(File.dirname(__FILE__)).gsub('lib', 'data/config.yaml'))).map {|k, v| [k.to_sym, v]}]
end
