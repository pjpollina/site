# Wrapper for SQL database client used for blog

require 'website/mysql'

module Website
  module Blog
    class Database
      def initialize
        @mysql = MySQL.new('blogapp', ENV['mysql_blogapp_password'], 'blog')
      end

      # Post Insert/Update/Delete statements
      def insert(title, slug, desc, body, category)
        @mysql.connect do |client|
          stmt = client.prepare("INSERT INTO posts(post_title, post_slug, post_desc, post_body, post_category) VALUES(?, ?, ?, ?, ?)")
          stmt.execute(title, slug, desc, body, category)
          unless(categories.include?(category))
            stmt = client.prepare("INSERT INTO categories VALUES(?, '')")
            stmt.execute(category)
          end
          stmt.close
        end
      end

      def update(slug, body)
        @mysql.connect do |client|
          stmt = client.prepare("UPDATE posts SET post_body=? WHERE post_slug=?")
          stmt.execute(body, slug)
          stmt.close
        end
      end

      def delete(slug)
        @mysql.connect do |client|
          stmt = client.prepare("DELETE FROM posts WHERE post_slug=?")
          stmt.execute(slug)
          stmt.close
        end
      end

      # Info checkers
      def title_free?(title)
        result = false
        @mysql.connect do |client|
          stmt = client.prepare("SELECT EXISTS(SELECT * FROM posts WHERE post_title=?) AS used")
          result = stmt.execute(title, symbolize_keys: true).first[:used] == 0
          stmt.close
        end
        return result
      end

      def slug_free?(slug)
        result = false
        @mysql.connect do |client|
          stmt = client.prepare("SELECT EXISTS(SELECT * FROM posts WHERE post_slug=?) AS used")
          result = stmt.execute(slug, symbolize_keys: true).first[:used] == 0
          stmt.close
        end
        return result
      end

      # Post getters
      def get_post(slug)
        Post.from_slug(@mysql, slug)
      end

      def month_posts(month, year)
        Post.from_month(@mysql, month, year)
      end

      def recent_posts(quantity)
        Post.recent(@mysql, quantity)
      end

      # Category functions
      def categories
        Category.all(@mysql)
      end

      def get_category(slug)
        Category.from_name(@mysql, Utils.slug_to_name(slug))
      end

      # Archive info getters
      def get_first_year
        @mysql.connect do |client|
          stmt = client.prepare("SELECT YEAR(post_timestamp) AS year FROM posts ORDER BY post_timestamp ASC LIMIT 1")
          year = stmt.execute(symbolize_keys: true).first[:year]
          stmt.close
          return year
        end
      end

      def get_period_count(month, year)
        @mysql.connect do |client|
          stmt = client.prepare("SELECT COUNT(*) AS count FROM posts WHERE MONTH(post_timestamp)=? AND YEAR(post_timestamp)=?")
          count = stmt.execute(month, year, symbolize_keys: true).first[:count]
          stmt.close
          return count
        end
      end

      def get_month_counts(year)
        counts = {}
        (1..12).each do |month|
          count = get_period_count(month, year)
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
        Category.counts(@mysql)
      end
    end
  end
end
