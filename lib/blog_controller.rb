# Class that controls all blog features of the site

require 'mysql2'
require './lib/blog_post.rb'
require './lib/http_server.rb'
require './lib/page_builder.rb'

class BlogController
  attr_reader :site_name

  LAYOUT = 'layout.erb'

  VIEWS = {
    homepage:  'homepage.erb',
    archive:   'archive.erb',
    new_post:  'new_post.erb',
    post:      'post.erb',
    edit_post: 'edit_post.erb'
  }

  def initialize
    @site_name = ENV['blogapp_site_name']
    @sql_client = Mysql2::Client.new(username: 'blogapp', password: ENV['mysql_blogapp_password'], database: 'blog')
  end

  def respond(path, admin)
    @admin = admin
    if path == '/'
      render_homepage
    elsif path == '/archive'
      render_archive
    elsif path == '/new_post'
      render_new_post
    elsif path.start_with?('/error_403')
      render_403
    else
      if(path.end_with?('?edit=true'))
        render_post_editor(path[1..-1].chomp('?edit=true'))
      else
        render_post(path[1..-1])
      end
    end
  end

  # Page Renderers
  def render_homepage
    layout = PageBuilder::load_layout(LAYOUT)
    context = PageBuilder::page_info(@site_name, "Home", @admin)
    page = layout.render(context) do
      PageBuilder::load_view(VIEWS[:homepage]).render(nil, recent_posts: recent_posts(5))
    end
    HTTPServer.html_response(page)
  end

  def render_archive
    layout = PageBuilder::load_layout(LAYOUT)
    context = PageBuilder::page_info(@site_name, "Archive", @admin)
    page = layout.render(context) do
      PageBuilder::load_view(VIEWS[:archive]).render(nil, archive: fetch_archive)
    end
    HTTPServer.html_response(page)
  end

  def render_new_post
    if(@admin)
      layout = PageBuilder::load_layout(LAYOUT)
      context = PageBuilder::page_info(@site_name, "New Post", @admin)
      page = layout.render(context) do
        PageBuilder::load_view(VIEWS[:new_post]).render(nil)
      end
      HTTPServer.html_response(page)
    else
      render_403
    end
  end

  def render_post(slug)
    data = stmt_from_slug.execute(slug).first
    if data.nil?
      render_404
    else
      post = BlogPost.new(data)
      layout = PageBuilder::load_layout(LAYOUT)
      context = PageBuilder::page_info(@site_name, post.title, @admin)
      page = layout.render(context) do
        PageBuilder::load_view(VIEWS[:post]).render(nil, post: post, admin: @admin)
      end
      HTTPServer.html_response(page)
    end
  end

  def render_post_editor(slug)
    if(@admin)
      data = stmt_from_slug.execute(slug).first
      if data.nil?
        render_404
      else
        post = BlogPost.new(data)
        layout = PageBuilder::load_layout(LAYOUT)
        context = PageBuilder::page_info(@site_name, "Editing Post #{post.title}", @admin)
        page = layout.render(context) do
          PageBuilder::load_view(VIEWS[:edit_post]).render(nil, post: post, slug: slug)
        end
        HTTPServer.html_response(page)
      end
    else
      render_403
    end
  end

  def render_403(simple=false)
    page = File.read("#{HTTPServer::WEB_ROOT}403.html")
    unless(simple)
      layout = PageBuilder::load_layout(LAYOUT)
      context = PageBuilder::page_info(@site_name, "403", @admin)
      page = layout.render(context) do
        page
      end
    end
    HTTPServer::html_response(page, 403, 'Forbidden')
  end

  def render_404
    layout = PageBuilder::load_layout(LAYOUT)
    context = PageBuilder::page_info(@site_name, "404", @admin)
    page = layout.render(context) do
      File.read("#{HTTPServer::WEB_ROOT}404.html")
    end
    HTTPServer::html_response(page, 404, 'Not Found')
  end

  # POST processors
  def post_new_blogpost(form_data, admin)
    unless(admin)
      return render_403(true)
    end
    elements = HTTPServer.parse_form_data(form_data)
    errors = validate_post(elements)
    unless(errors == {})
      errmesg = ''
      errors.each do |type, message|
        errmesg << "#{type} error: #{message}\n" 
      end
      return "HTTP/1.1 409 Conflict\r\n\r\n#{errmesg.chomp}\r\n\r\n"
    else
      insert_new_post(elements)
      return "HTTP/1.1 201 Created\r\nLocation: /#{elements['slug']}\r\n\r\n/#{elements['slug']}\r\n\r\n"
    end
  end

  def post_admin_login(form_data, ip)
    password = HTTPServer.parse_form_data(form_data)['password']
    if(password == ENV['blogapp_author_password'])
      return HTTPServer.login_admin(ip)
    else
      return "HTTP/1.1 401 Unauthorized\r\n\r\nFoobazz\r\n\r\n"
    end
  end

  # PUT processors
  def put_updated_blogpost(form_data, admin)
    unless(admin)
      return render_403(true)
    end
    elements = HTTPServer.parse_form_data(form_data)
    update_post(elements)
    return HTTPServer.redirect(elements["slug"])
  end

  # DELETE processors
  def delete_blogpost(form_data, admin)
    unless(admin)
      return render_403(true)
    end
    elements = HTTPServer.parse_form_data(form_data)
    delete_post(elements)
    return HTTPServer.redirect('/')
  end

  # Data fetchers
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
    last_post = stmt_last_post_id.execute.first
    if last_post.nil?
      return 0
    else
      return 1 + stmt_last_post_id.execute.first['post_id']
    end
  end

  # Data editors
  def insert_new_post(values)
    stmt_insert_new_post.execute(
      next_post_id,
      @sql_client.escape(values['title']),
      @sql_client.escape(values['slug']),
      values['body']
    )
  end

  def update_post(values)
    stmt_update_post.execute(values['body'], values['slug'])
  end

  def delete_post(values)
    stmt_delete_post.execute(values['slug'])
  end

  # Validators
  def validate_post(values)
    all_posts = recent_posts
    errors = {}
    if !slug_valid?(values['slug'])
      errors[:slug] = "Invalid slug!"
    elsif !slug_unique?(values['slug'])
      errors[:slug] = "Slug already in use!"
    end
    if all_posts.any? {|post| post['post_title'] == values['title']}
      errors[:title] = "Title already in use!"
    end
    errors
  end

  def slug_valid?(slug)
    regexp = /^[A-Za-z0-9]+(?:[A-Za-z0-9_-]+[A-Za-z0-9]){0,255}$/
    !(regexp =~ slug).nil?
  end

  def slug_unique?(slug)
    !recent_posts.any? {|post| post['post_slug'] == slug}
  end

  def title_valid?(title)
    stmt_title_check.execute(title).first.nil?
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
      ORDER BY post_id DESC
      LIMIT 1
    SQL
  end

  def stmt_insert_new_post
    @stmt_insert_new_post ||= @sql_client.prepare <<~SQL
      INSERT INTO posts(post_id, post_title, post_slug, post_body)
      VALUES(?, ?, ?, ?)
    SQL
  end

  def stmt_title_check
    @stmt_title_check ||= @sql_client.prepare <<~SQL
      SELECT post_id FROM posts WHERE post_title=?
    SQL
  end

  def stmt_update_post
    @stmt_update_post ||= @sql_client.prepare <<~SQL
      UPDATE posts
      SET post_body=?
      WHERE post_slug=?
    SQL
  end

  def stmt_delete_post
    @stmt_delete_post ||= @sql_client.prepare <<~SQL
      DELETE FROM posts
      WHERE post_slug=?
    SQL
  end
end
