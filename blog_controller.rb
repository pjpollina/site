# Class that controls all blog features of the site

require 'erb'
require 'mysql2'
require './blog_post.rb'
require './http_server.rb'

class BlogController
  attr_reader :page_name

  TEMPLATES = {
    homepage: ERB.new(File.read './public/templates/blog_home.erb'),
    archive:  ERB.new(File.read './public/templates/blog_archive.erb')
  }

  def initialize(sql_client: nil, page_name: nil)
    @page_name = page_name || "PJ's Site"
    @sql_client = sql_client || Mysql2::Client.new(username: 'blog_server', password: '', database: 'blog')
  end

  def respond(path)
    if path == '/'
      render_homepage
    elsif path == '/archive'
      render_archive
    else
      render_post(path[1..-1])
    end
  end

  def render_homepage
    recent_posts = recent_posts(5)
    HTTPServer.generic_html(TEMPLATES[:homepage].result(binding))
  end

  def render_archive
    archive = fetch_archive
    HTTPServer.generic_html(TEMPLATES[:archive].result(binding))
  end

  def render_post(slug)
    data = stmt_from_slug.execute(slug).first
    if data.nil?
      HTTPServer.generic_404
    else
      post = BlogPost.new(data)
      HTTPServer.generic_html(post.render)
    end
  end

  def recent_posts(count=65536)
    stmt_n_most_recent.execute(count)
  end

  def fetch_archive
    archive = {}
    active_year, active_month = nil, nil
    recent_posts.each do |post|
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

  def next_post_id
    1 + stmt_last_post_id.execute.first['post_id']
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

  def stmt_last_post_id
    @stmt_last_post_id ||= @sql_client.prepare <<~SQL
      SELECT post_id
      FROM posts
      ORDER BY post_timestamp DESC
      LIMIT 1
    SQL
  end
end