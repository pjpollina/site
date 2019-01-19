# Class for a blog post object

require 'kramdown'

module Website::Blog
  class Post
    attr_reader :title, :slug, :body, :timestamp

    def initialize(title, slug, body, timestamp)
      @title     = title
      @slug      = slug
      @body      = body
      @timestamp = timestamp
    end

    def date_formatted
      @date.strftime("%B %d, %Y")
    end

    def parsed_body
      Kramdown::Document.new(@body).to_html
    end
  end
end
