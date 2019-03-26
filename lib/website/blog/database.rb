# Wrapper for SQL database client used for blog

require 'mysql2'

module Website
  module Blog
    class Database
      def initialize
        # MySQL client
        @sql_client = Mysql2::Client.new(username: 'blogapp', password: ENV['mysql_blogapp_password'], database: 'blog')
        # Post Insert/Update/Delete statements
        @insert = @sql_client.prepare "INSERT INTO posts(post_title, post_slug, post_desc, post_body, post_category) VALUES(?, ?, ?, ?, ?)"
        @update = @sql_client.prepare "UPDATE posts SET post_body=? WHERE post_slug=?"
        @delete = @sql_client.prepare "DELETE FROM posts WHERE post_slug=?"
        # Info checkers
        @title_free = @sql_client.prepare "SELECT EXISTS(SELECT * FROM posts WHERE post_title=?) AS used"
        @slug_free  = @sql_client.prepare "SELECT EXISTS(SELECT * FROM posts WHERE post_slug =?) AS used"
        # Post getters
        @get_post       = @sql_client.prepare "SELECT * FROM posts WHERE post_slug=?"
        @month_posts    = @sql_client.prepare "SELECT * FROM posts WHERE MONTH(post_timestamp)=? AND YEAR(post_timestamp)=? ORDER BY post_timestamp"
        @recent_posts   = @sql_client.prepare "SELECT * FROM posts ORDER BY post_timestamp DESC LIMIT ?"
        @category_posts = @sql_client.prepare "SELECT * FROM posts WHERE post_category=? ORDER BY post_timestamp"
        # Category functions
        @categories   = @sql_client.prepare "SELECT cat_name FROM categories"
        @get_category = @sql_client.prepare "SELECT cat_name, cat_desc FROM categories WHERE cat_name=?"
        # Archive info getters
        @get_first_year     = @sql_client.prepare "SELECT YEAR(post_timestamp) AS year FROM posts ORDER BY post_timestamp  ASC LIMIT 1"
        @get_period_count   = @sql_client.prepare "SELECT COUNT(*) FROM posts WHERE MONTH(post_timestamp)=? AND YEAR(post_timestamp)=?"
        @get_category_count = @sql_client.prepare "SELECT COUNT(*) FROM posts WHERE post_category=?"
      end

      # Post Insert/Update/Delete statements
      def insert(title, slug, desc, body, category)
        @insert.execute(title, slug, desc, body, category)
        unless(categories.include?(category))
          @sql_client.query("INSERT INTO categories VALUES('#{category}', '')")
        end
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
        Post.new(data[:post_title], slug, data[:post_desc], data[:post_body], data[:post_category], data[:post_timestamp])
      end

      def recent_posts(quantity)
        @recent_posts.execute(quantity, symbolize_keys: true)
      end

      # Category functions
      def categories
        @categories.execute(as: :array).collect {|cat| cat[0]}
      end

      def get_category(slug)
        data = @get_category.execute(Utils.slug_to_name(slug), symbolize_keys: true).first
        return nil if data.nil?
        Category.new(data[:cat_name], data[:cat_desc], @category_posts.execute(data[:cat_name], symbolize_keys: true))
      end

      # Archive info getters
      def get_first_year
        @get_first_year.execute(symbolize_keys: true).first[:year]
      end

      def get_month_counts(year)
        counts = {}
        (1..12).each do |month|
          count = @get_period_count.execute(month, year).first['COUNT(*)']
          unless(count == 0)
            counts[month] = count
          end
        end
        counts
      end

      def get_full_archive
        archive = {}
        (get_first_year..Time.now.year).each do |year|
          archive[year] = get_month_counts(year)
        end
        archive
      end

      def get_category_counts
        counts = {}
        categories.each do |category|
          counts[category] = @get_category_count.execute(category).first['COUNT(*)']
        end
        counts
      end
    end
  end
end
