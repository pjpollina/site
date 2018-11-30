# Class for a blog post object
# Models data from table defined at schema/posts.sql

require 'kramdown'

class BlogPost
  attr_reader :title, :body

  def initialize(data = {})
    @title  = data['post_title']
    @date   = data['post_timestamp']
    @body   = Kramdown::Document.new(data['post_body']).to_html
  end

  def date
    @date.strftime("%B %d, %Y")
  end
end