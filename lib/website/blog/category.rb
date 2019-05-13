# Class for a blog category object

require 'website/path_pattern'

module Website
  module Blog
    class Category
      PATTERN = PathPattern.new("/category/:cat")

      attr_reader :name, :desc, :posts

      def initialize(name, desc, posts)
        @name  = name
        @desc  = desc
        @posts = posts
      end

      def self.all(mysql)
        cats = []
        mysql.connect do |client|
          cats = client.query("SELECT cat_name FROM categories", as: :array).collect(&:first)
        end
        return cats
      end
    end
  end
end
