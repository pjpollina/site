# Class for a blog post object
# Models data from table defined at schema/posts.sql

require 'erb'
require 'kramdown'

class BlogPost
  attr_reader :title, :date, :body

  PAGE_TEMPLATE = ERB.new(File.read './public/templates/blog_post.erb')

  def initialize(data = {})
    @title  = data['post_title']
    @date   = data['post_timestamp']
    @body   = Kramdown::Document.new(data['post_body']).to_html
  end

  def render(template=PAGE_TEMPLATE)
    template.result(binding)
  end
end