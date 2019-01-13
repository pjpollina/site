# A helper module for tilt-based rendering functions

require 'ostruct'
require 'tilt/erb'
require './lib/http_server.rb'

module PageBuilder
  VIEWS   = HTTPServer.web_file("templates/views")
  LAYOUTS = HTTPServer.web_file("templates/layouts")

  def self.page_info(site_name, page_name, admin)
    info = OpenStruct.new
    info.site_name = site_name
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
end
