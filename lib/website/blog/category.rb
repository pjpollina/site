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

      def self.from_name(mysql, name)
        cat = nil
        mysql.connect do |client|
          stmt = client.prepare("SELECT cat_name, cat_desc FROM categories WHERE cat_name=?")
          data = stmt.execute(name, symbolize_keys: true).first
          unless(data.nil?)
            stmt = client.prepare("SELECT * FROM posts WHERE post_category=? ORDER BY post_timestamp")
            posts = stmt.execute(data[:cat_name], symbolize_keys: true).collect do |data|
              Post.new(data[:post_title], data[:post_slug], data[:post_desc], data[:post_body], data[:post_category], data[:post_timestamp], data[:post_preview])
            end
            cat = new(data[:cat_name], data[:cat_desc], posts)
          end
          stmt.close
        end
        return cat
      end

      def self.counts(mysql)
        counts = Hash[all(mysql).collect {|cat| [cat, 0]}]
        mysql.connect do |client|
          stmt = client.prepare("SELECT COUNT(*) as count FROM posts WHERE post_category=?")
          counts.keys.each do |cat|
            counts[cat] = stmt.execute(cat).first['count']
          end
          stmt.close
        end
        return counts
      end
    end
  end
end
