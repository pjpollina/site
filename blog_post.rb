# Class for a blog post object
# Models data from table defined at schema/posts.sql

class BlogPost
  attr_reader :title, :date, :body

  def initialize(data = {})
    @title  = data['post_title']     || '404 Error'
    @date   = data['post_timestamp'] || '01-01-1970'
    @body   = data['post_body']      || 'Post not found'
  end

  def render(template)
    template.result(binding)
  end
end