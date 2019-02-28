# Class for a blog category object

require 'website/path_pattern'

module Website
  module Blog
    class Category
      attr_reader :name, :desc, :posts

      def initialize(name, desc, posts)
        @name  = name
        @desc  = desc
        @posts = posts
      end

      PATTERN = PathPattern.new("/category/:cat")

      def self.name_to_slug(name)
        name.downcase.gsub(' ', '_')
      end

      def self.slug_to_name(slug)
        words = slug.split('_').collect {|word| word.capitalize }
        words.join(' ')
      end
    end
  end
end
