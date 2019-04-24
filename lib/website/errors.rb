# Enum thing of HTTP errors that generate pages

require 'website/template'

module Website
  module Errors
    extend self

    Error = Struct.new(:status_code, :status_message, :page_message)

    TEMPLATE = Template.load_view("error.erb")

    ERRORS = {
      403 => Error.new(403, "Forbidden", "You're not allowed to do whatever you just tried to do."),
      404 => Error.new(404, "Not Found", "The requested content could not be found.")
    }

    def get_error(status_code)
      ERRORS[status_code] || Error.new(status_code, "Unknown", "The hack fraud who programmed this site forgot to add a response for this error.")
    end

    alias_method(:[], :get_error)

    def render_error(status_code)
      TEMPLATE.render(get_error(status_code))
    end
  end
end
