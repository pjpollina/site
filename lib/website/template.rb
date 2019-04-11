# Wrapper class for ERB templates

require 'ostruct'
require 'tilt/erb'
require 'website/utils'
require 'website/web_file'

module Website
  class Template
    ROOT = WebFile["/templates/"]

    def initialize(filename)
      @filename = filename
    end

    def render(variables={})
      template.render(OpenStruct.new(variables)) { yield }
    end

    alias_method(:[], :render)

    def template
      Tilt::ERBTemplate.new(ROOT + @filename)
    end

    def self.load_view(filename)
      Template.new("views/" + filename)
    end

    def self.load_layout(filename)
      Template.new("layouts/" + filename)
    end
  end
end
