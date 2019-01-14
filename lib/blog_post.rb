# Class for a blog post object
# Models data from table defined at schema/posts.sql

require 'kramdown'

module Website
  class BlogPost
    attr_reader :title

    def initialize(data = {})
      @title  = data['post_title']
      @date   = data['post_timestamp']
      @body   = data['post_body']
    end

    def date
      @date.strftime("%B %d, %Y")
    end

    def body
      Kramdown::Document.new(@body).to_html
    end

    def body_raw
      @body
    end
  end
end
