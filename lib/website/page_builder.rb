# A helper module for tilt-based rendering functions

require 'ostruct'
require 'tilt/erb'
require 'website/utils'

module Website
  module PageBuilder
    extend self

    VIEWS   = Utils.web_file("templates/views")
    LAYOUTS = Utils.web_file("templates/layouts")

    def load_view(name)
      Tilt::ERBTemplate.new("#{VIEWS}/#{name}")
    end

    def load_layout(name)
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
