# Class for a blog post object

require 'kramdown'

module Website
  module Blog
    class Post
      attr_reader :title, :slug, :body, :category, :timestamp

      def initialize(title, slug, body, category, timestamp)
        @title     = title
        @slug      = slug
        @body      = body
        @category  = category
        @timestamp = timestamp
      end

      def date_formatted
        @timestamp.strftime("%B %d, %Y")
      end

      def parsed_body
        Kramdown::Document.new(@body).to_html
      end
    end
  end
end
