# Wrapper for SQL database client used for blog

require 'mysql2'

module Website
  module Blog
    class Database
      def initialize
        # MySQL client
        @sql_client = Mysql2::Client.new(username: 'blogapp', password: ENV['mysql_blogapp_password'], database: 'blog')
        # Post Insert/Update/Delete statements
        @insert = @sql_client.prepare "INSERT INTO posts(post_title, post_slug, post_body, post_category) VALUES(?, ?, ?, ?)"
        @update = @sql_client.prepare "UPDATE posts SET post_body=? WHERE post_slug=?"
        @delete = @sql_client.prepare "DELETE FROM posts WHERE post_slug=?"
        # Info getters
        @title_free = @sql_client.prepare "SELECT EXISTS(SELECT * FROM posts WHERE post_title=?) AS used"
        @slug_free  = @sql_client.prepare "SELECT EXISTS(SELECT * FROM posts WHERE post_slug =?) AS used"
        # Post getters
        @get_post     = @sql_client.prepare "SELECT * FROM posts WHERE post_slug=?"
        @recent_posts = @sql_client.prepare "SELECT * FROM fullposts ORDER BY post_timestamp DESC LIMIT ?"
        # Category functions
        @categories     = @sql_client.prepare "SELECT cat_name FROM categories"
        @get_category   = @sql_client.prepare "SELECT cat_name, cat_desc FROM categories WHERE cat_slug=?"
        @category_posts = @sql_client.prepare "SELECT * FROM fullposts WHERE cat_name=? ORDER BY post_timestamp"
      end

      # Post modifiers
      def insert(title, slug, body, category)
        @insert.execute(title, slug, body, category)
      end

      def update(slug, body)
        @update.execute(body, slug)
      end

      def delete(slug)
        @delete.execute(slug)
      end

      # Info checkers
      def title_free?(title)
        @title_free.execute(title, symbolize_keys: true).first[:used] == 0
      end

      def slug_free?(slug)
        @slug_free.execute(slug, symbolize_keys: true).first[:used] == 0
      end

      # Post getters
      def get_post(slug)
        data = @get_post.execute(slug, symbolize_keys: true).first
        return nil if(data.nil?)
        Post.new(data[:post_title], slug, data[:post_body], data[:post_category], data[:post_timestamp])
      end

      def recent_posts(quantity)
        @recent_posts.execute(quantity, symbolize_keys: true)
      end

      # Category functions
      def categories
        @categories.execute(as: :array).collect {|cat| cat[0]}
      end

      def get_category(slug)
        data = @get_category.execute(slug, symbolize_keys: true).first
        return nil if data.nil?
        Category.new(data[:cat_name], slug, data[:cat_desc], @category_posts.execute(data[:cat_name], symbolize_keys: true))
      end

      def category_check(name)
        @catcheck ||= {
          insert: @sql_client.prepare("INSERT IGNORE INTO categories(cat_id, cat_name, cat_desc) VALUES(?, ?, '')"),
          select: @sql_client.prepare("SELECT cat_id FROM categories WHERE cat_name=?")
        }
        id = @sql_client.query("SELECT COALESCE(MAX(cat_id) + 1, 0) FROM categories", as: :array).first.first
        @catcheck[:insert].execute(id, name)
        @catcheck[:select].execute(name, as: :array).first.first
      end
    end
  end
end
