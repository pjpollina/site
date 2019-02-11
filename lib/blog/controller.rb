# Class that controls all blog features of the site

require './lib/http_server.rb'
require './lib/path_pattern.rb'
require './lib/blog/post.rb'
require './lib/blog/category.rb'
require './lib/blog/database.rb'
require './lib/blog/renderer.rb'

module Website
  module Blog
    class Controller
      def initialize
        @ip_login_attempts = Hash.new(0)
        @database = Database.new
      end

      def respond(path, admin)
        @category_pattern ||= PathPattern.new("/category/:cat")
        case path
        when '/'
          Renderer.render_page("Home", :homepage, admin, false, recent_posts: @database.recent_posts(6))
        when '/archive'
          Renderer.render_page("Archive", :archive, admin, false, archive: fetch_archive)
        when '/new_post'
          Renderer.render_page("New Post", :new_post, admin, true, categories: @database.categories)
        when @category_pattern
          cat = @database.get_category(@category_pattern[path][:cat])
          unless(cat.nil?)
            Renderer.render_page(cat.name, :category, admin, false, cat: cat)
          else
            Renderer.render_404(admin)
          end
        else
          post = @database.get_post(path[1..-1].chomp('?edit=true'))
          Renderer.render_post_page(post, admin, path.end_with?('?edit=true'))
        end
      end

      # POST processors
      def post_new_blogpost(form_data, admin)
        unless(admin)
          return Renderer.render_403(admin, true)
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
          @database.insert(elements[:title], elements[:slug], elements[:body], elements[:category])
          return "HTTP/1.1 201 Created\r\nLocation: /#{elements[:slug]}\r\n\r\n/#{elements[:slug]}\r\n\r\n"
        end
      end

      def post_admin_login(form_data, ip)
        unless(@ip_login_attempts[ip] >= 3)
          @ip_login_attempts[ip] += 1
          password = HTTPServer.parse_form_data(form_data)[:password]
          if(password == ENV['blogapp_author_password'])
            @ip_login_attempts[ip] = 0
            return HTTPServer.login_admin(ip)
          end
        end
        return "HTTP/1.1 401 Unauthorized\r\n\r\nFoobazz\r\n\r\n"
      end

      # PUT processors
      def put_updated_blogpost(form_data, admin)
        unless(admin)
          return Renderer.render_403(admin, true)
        end
        elements = HTTPServer.parse_form_data(form_data)
        @database.update(elements[:slug], elements[:body])
        return HTTPServer.redirect(elements[:slug])
      end

      # DELETE processors
      def delete_blogpost(form_data, admin)
        unless(admin)
          return Renderer.render_403(admin, true)
        end
        elements = HTTPServer.parse_form_data(form_data)
        @database.delete(elements[:slug])
        return HTTPServer.redirect('/')
      end

      # Data fetchers
      def fetch_archive
        archive = {}
        active_year, active_month = nil, nil
        @database.recent_posts(65536).each do |post|
          ts = post[:post_timestamp]
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

      # Validators
      def validate_post(values)
        errors = {}
        unless(field_free?(:title, values[:title]) && field_free?(:slug, values[:slug]))
          errors[:conflict] = "Title or slug already in use!"
        end
        errors
      end

      def field_free?(field, value)
        case field
        when :title
          @database.title_free?(value)
        when :slug
          @database.slug_free?(value)
        else
          false
        end
      end
    end
  end
end
