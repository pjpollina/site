# Class that controls all blog features of the site
# ...er, eventually

require 'mysql2'
require './blog_post.rb'
require './http_server.rb'

class BlogController
  def initialize(sql_client: nil)
    @sql_client = sql_client || Mysql2::Client.new(username: 'blog_server', password: '', database: 'blog')
  end

  def parse_slug_request(slug)
    data = stmt_from_slug.execute(slug).first
    if data.nil?
      HTTPServer.generic_404
    else
      post = BlogPost.new(data)
      HTTPServer.generic_html(post.render)
    end
  end

  def recent_posts(count)
    stmt_n_most_recent.execute(count)
  end

  def all_posts
    recent_posts(65536)
  end

  def fetch_archive
    archive = {}
    active_year, active_month = nil, nil
    all_posts.each do |post|
      ts = post['post_timestamp']
      if active_year != ts.year
        archive[ts.year] = {}
        active_year = ts.year
      end
      if active_month != ts.strftime('%B')
        archive[active_year][ts.strftime('%B')] = []
        active_month = ts.strftime('%B')
      end
      archive[active_year][active_month] << post
    end
    archive
  end

  private

  def stmt_from_slug
    @stmt_from_slug ||= @sql_client.prepare <<~SQL
      SELECT post_title, post_body, post_timestamp
      FROM posts
      WHERE post_slug=?
    SQL
  end

  def stmt_n_most_recent
    @stmt_n_most_recent ||= @sql_client.prepare <<~SQL
      SELECT post_slug, post_title, post_timestamp
      FROM posts
      ORDER BY post_timestamp DESC
      LIMIT ?
    SQL
  end
end