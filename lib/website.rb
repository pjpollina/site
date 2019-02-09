# Global hash of configuration settings
# Loads file ./data/config.yaml

require 'yaml'

module Website
  $config_info = Hash[YAML.load(File.read('./data/config.yaml')).map {|k, v| [k.to_sym, v]}]
end
