# Global hash of configuration settings
# Loads file ./etc/config.yaml

require 'yaml'

module Website
  $config_info = Hash[YAML.load(File.read('./etc/config.yaml')).map {|k, v| [k.to_sym, v]}]
end
