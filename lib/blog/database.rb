# Wrapper for SQL database client used for blog

require 'mysql2'

module Website::Blog
  class Database
    def initialize
      # MySQL client
      @sql_client = Mysql2::Client.new(username: 'blogapp', password: ENV['mysql_blogapp_password'], database: 'blog')
      # Post Insert/Update/Delete statements
      @insert = @sql_client.prepare "INSERT INTO posts(post_id, post_title, post_slug, post_body, post_category) VALUES(?, ?, ?, ?, ?)"
      @update = @sql_client.prepare "UPDATE posts SET post_body=? WHERE post_slug=?"
      @delete = @sql_client.prepare "DELETE FROM posts WHERE post_slug=?"
      # Info getters
      @next_id    = @sql_client.prepare "SELECT COALESCE(MAX(post_id) + 1, 0) AS next_id FROM posts"
      @title_free = @sql_client.prepare "SELECT EXISTS(SELECT * FROM posts WHERE post_title=?) AS used"
      @slug_free  = @sql_client.prepare "SELECT EXISTS(SELECT * FROM posts WHERE post_slug =?) AS used"
      # Post getters
      @get_post     = @sql_client.prepare "SELECT * FROM fullposts WHERE post_slug=?"
      @recent_posts = @sql_client.prepare "SELECT *, SUBSTRING_INDEX(post_body, '\r\n', 1) AS post_preview FROM fullposts ORDER BY post_timestamp DESC LIMIT ?"
      # Category functions
      @categories       = @sql_client.prepare "SELECT cat_name FROM categories"
      @get_category     = @sql_client.prepare "SELECT cat_name, cat_desc FROM categories WHERE cat_slug=?"
      @category_check_a = @sql_client.prepare "INSERT IGNORE INTO categories(cat_id, cat_name, cat_desc) VALUES(?, ?, '')"
      @category_check_b = @sql_client.prepare "SELECT cat_id FROM categories WHERE cat_name=?"
      @category_posts   = @sql_client.prepare "SELECT *, SUBSTRING_INDEX(post_body, '\r\n', 1) AS post_preview FROM fullposts WHERE cat_name=? ORDER BY post_timestamp"
    end

    # Post modifiers
    def insert(title, slug, body, category)
      @insert.execute(available_id, title, slug, body, category_check(category))
    end

    def update(slug, body)
      @update.execute(body, slug)
    end

    def delete(slug)
      @delete.execute(slug)
    end

    # Info checkers
    def available_id
      @next_id.execute.first['next_id']
    end

    def title_free?(title)
      @title_free.execute(title).first['used'] == 0
    end

    def slug_free?(slug)
      @slug_free.execute(slug).first['used'] == 0
    end

    # Post getters
    def get_post(slug)
      data = @get_post.execute(slug).first
      return nil if(data.nil?)
      Post.new(data['post_title'], slug, data['post_body'], data['cat_name'], data['post_timestamp'])
    end

    def recent_posts(quantity)
      @recent_posts.execute(quantity)
    end

    # Category functions
    def categories
      @categories.execute(as: :array).collect {|cat| cat[0]}
    end

    def get_category(slug)
      data = @get_category.execute(slug).first
      return nil if data.nil?
      Category.new(data['cat_name'], slug, data['cat_desc'], @category_posts.execute(data['cat_name']))
    end

    def category_check(name)
      id = @sql_client.query("SELECT COALESCE(MAX(cat_id) + 1, 0) FROM categories", as: :array).first.first
      @category_check_a.execute(id, name)
      @category_check_b.execute(name, as: :array).first.first
    end
  end
end
