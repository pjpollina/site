# A helper module for tilt-based rendering functions

require 'ostruct'
require 'tilt/erb'

module Website
  module PageBuilder
    VIEWS   = Website.web_file("templates/views")
    LAYOUTS = Website.web_file("templates/layouts")

    def self.load_view(name)
      Tilt::ERBTemplate.new("#{VIEWS}/#{name}")
    end

    def self.load_layout(name)
      Tilt::ERBTemplate.new("#{LAYOUTS}/#{name}")
    end
  end

  class PageBuilder::Layout
    def initialize(name)
      @name = name
    end

    def [](page_name, admin)
      PageBuilder.load_layout(@name).render(OpenStruct.new(page_name: page_name, admin: admin)) do
        yield
      end
    end
  end

  class PageBuilder::View
    def initialize(name)
      @name = name
    end

    def [](locals={})
      PageBuilder.load_view(@name).render(OpenStruct.new(locals))
    end
  end
end
