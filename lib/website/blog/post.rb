# Class for a blog post object

require 'kramdown'

module Website
  module Blog
    class Post
      attr_reader :title, :slug, :desc, :body, :category, :timestamp, :preview

      def initialize(data)
        @title     = data[:post_title]
        @slug      = data[:post_slug]
        @desc      = data[:post_desc]
        @body      = data[:post_body]
        @category  = data[:post_category]
        @timestamp = data[:post_timestamp]
        @preview   = data[:post_preview]
      end

      def date_formatted
        @timestamp.strftime("%B %d, %Y")
      end

      def parsed_body
        Kramdown::Document.new(@body).to_html
      end

      def category_link
        '<a href="/category/' << Utils.name_to_slug(@category) << '">' << @category << '</a>'
      end

      def self.from_slug(mysql, slug)
        post = nil
        mysql.connect do |client|
          stmt = client.prepare("SELECT * FROM posts WHERE post_slug=?")
          data = stmt.execute(slug, symbolize_keys: true).first
          unless(data.nil?)
            post = new(data[:post_title], slug, data[:post_desc], data[:post_body], data[:post_category], data[:post_timestamp])
          end
          stmt.close
        end
        return post
      end

      def self.recent(mysql, limit)
        posts = []
        mysql.connect do |client|
          stmt = client.prepare("SELECT * FROM posts ORDER BY post_timestamp DESC LIMIT ?")
          stmt.execute(limit, symbolize_keys: true).each do |data|
            posts << new(data[:post_title], data[:post_slug], data[:post_desc], data[:post_body], data[:post_category], data[:post_timestamp], data[:post_preview])
          end
          stmt.close
        end
        return posts
      end

      def self.from_month(mysql, month, year)
        posts = []
        mysql.connect do |client|
          stmt = client.prepare("SELECT * FROM posts WHERE MONTH(post_timestamp)=? AND YEAR(post_timestamp)=? ORDER BY post_timestamp")
          posts = stmt.execute(month, year, symbolize_keys: true).collect do |data|
            Post.new(data[:post_title], data[:post_slug], data[:post_desc], data[:post_body], data[:post_category], data[:post_timestamp], data[:post_preview])
          end
          stmt.close
        end
        return posts
      end
    end
  end
end
