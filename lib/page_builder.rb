# A helper module for tilt-based rendering functions

require 'ostruct'
require 'tilt/erb'
require './lib/http_server.rb'

module Website
  module PageBuilder
    VIEWS   = HTTPServer.web_file("templates/views")
    LAYOUTS = HTTPServer.web_file("templates/layouts")

    def self.page_info(page_name, admin)
      info = OpenStruct.new
      info.page_name = page_name
      info.admin = admin
      return info
    end

    def self.load_view(name)
      Tilt::ERBTemplate.new("#{VIEWS}/#{name}")
    end

    def self.load_layout(name)
      Tilt::ERBTemplate.new("#{LAYOUTS}/#{name}")
    end

    class Layout
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def [](page_name, admin)
        PageBuilder.load_layout(@name).render(PageBuilder.page_info(page_name, admin)) do
          yield
        end
      end
    end

    class View
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def [](locals={})
        PageBuilder.load_view(@name).render(OpenStruct.new(locals))
      end
    end
  end
end
