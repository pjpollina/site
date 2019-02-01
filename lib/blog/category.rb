# Class for a blog category object

class Website::Blog::Category
  attr_reader :name, :slug, :desc, :posts

  def initialize(name, slug, desc, posts)
    @name  = name
    @slug  = slug
    @desc  = desc
    @posts = posts
  end

  def self.name_to_slug(name)
    name.downcase.gsub(' ', '_')
  end
end