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
    end
  end
end
