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
      @categories = @sql_client.prepare "SELECT DISTINCT post_category FROM posts"
      # Post getters
      @get_post       = @sql_client.prepare "SELECT post_title, post_body, post_category, post_timestamp FROM posts WHERE post_slug=?"
      @recent_posts_1 = @sql_client.prepare "SELECT post_slug, post_title, post_category, post_timestamp FROM posts ORDER BY post_timestamp DESC LIMIT ?"
      @recent_posts_2 = @sql_client.prepare <<~SQL
        SELECT post_slug, post_title, post_category, post_timestamp, SUBSTRING_INDEX(post_body, "\r\n", 1) AS post_preview
        FROM posts ORDER BY post_timestamp DESC LIMIT ?
      SQL
      @category_posts = @sql_client.prepare <<~SQL
        SELECT post_slug, post_title, post_category, post_timestamp, SUBSTRING_INDEX(post_body, "\r\n", 1) AS post_preview
        FROM posts WHERE post_category=?
      SQL
    end

    # Post modifiers
    def insert(title, slug, body, category)
      @insert.execute(available_id, title, slug, body, category)
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

    def categories
      @categories.execute({as: :array}).collect {|cat| cat[0]}
    end

    # Post getters
    def get_post(slug)
      data = @get_post.execute(slug).first
      return nil if(data.nil?)
      Post.new(data['post_title'], slug, data['post_body'], data['post_category'], data['post_timestamp'])
    end

    def recent_posts(previews, quantity)
      statement = ((previews) ? @recent_posts_2 : @recent_posts_1)
      statement.execute(quantity)
    end

    def category_posts(category)
      @category_posts.execute(category)
    end
  end
end
