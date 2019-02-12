# A helper module for tilt-based rendering functions

require 'ostruct'
require 'tilt/erb'
require 'http_server'

module Website
  module PageBuilder
    VIEWS   = HTTPServer.web_file("templates/views")
    LAYOUTS = HTTPServer.web_file("templates/layouts")

    def self.load_view(name)
      Tilt::ERBTemplate.new("#{VIEWS}/#{name}")
    end

    def self.load_layout(name)
      Tilt::ERBTemplate.new("#{LAYOUTS}/#{name}")
    end

    class Layout
      def initialize(name)
        @name = name
      end

      def [](page_name, admin)
        PageBuilder.load_layout(@name).render(OpenStruct.new(page_name: page_name, admin: admin)) do
          yield
        end
      end
    end

    class View
      def initialize(name)
        @name = name
      end

      def [](locals={})
        PageBuilder.load_view(@name).render(OpenStruct.new(locals))
      end
    end
  end
end
