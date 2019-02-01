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

  def self.slug_to_name(slug)
    words = slug.split('_').collect {|word| word.capitalize }
    words.join(' ')
  end
end