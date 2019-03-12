# Class for a blog post object

require 'kramdown'

module Website
  module Blog
    class Post
      attr_reader :title, :slug, :desc, :body, :category, :timestamp

      def initialize(title, slug, desc, body, category, timestamp)
        @title     = title
        @slug      = slug
        @desc      = desc
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

      def category_link
        '<a href="/category/' << Category.name_to_slug(@category) << '">' << @category << '</a>'
      end
    end
  end
end
