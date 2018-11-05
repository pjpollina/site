# Class for a blog post object
# Models data from table defined at schema/posts.sql

require 'erb'

class BlogPost
  attr_reader :title, :date, :body

  PAGE_TEMPLATE = ERB.new(File.read './templates/blog_post.erb')

  def initialize(data = {})
    @title  = data['post_title']     || '404 Error'
    @date   = data['post_timestamp'] || '01-01-1970'
    @body   = data['post_body']      || 'Post not found'
  end

  def render(template=PAGE_TEMPLATE)
    template.result(binding)
  end
end