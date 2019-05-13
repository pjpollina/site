# Class for a blog post object

require 'kramdown'

module Website
  module Blog
    class Post
      attr_reader :title, :slug, :desc, :body, :category, :timestamp

      def initialize(title, slug, desc, body, category, timestamp)
        @title     = title
        @slug      = slug
        @desc      = desc
        @body      = body
        @category  = category
        @timestamp = timestamp
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
          stmt.execute(limit, symbolize_keys: true).each {|post| posts << post }
          stmt.close
        end
        return posts
      end
    end
  end
end
