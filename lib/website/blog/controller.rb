# Class that controls all blog features of the site

module Website
  module Blog
    class Controller
      MONTH_PATTERN = PathPattern.new("/archive/:year/:month")

      def initialize
        @ip_login_attempts = Hash.new(0)
        @database = Database.new
        @rss_feed = RSS.new
        @rss_feed.update(@database)
      end

      def respond(path, admin)
        case path
        when '/'
          Renderer.render_page("Home", :homepage, admin, false, recent_posts: @database.recent_posts(6))
        when '/archive'
          Renderer.render_page("Archive", :archive, admin, false, archive: fetch_archive, archives: @database.get_full_archive, categories: @database.categories, counts: @database.get_category_counts)
        when '/new_post'
          Renderer.render_page("New Post", :new_post, admin, true, categories: @database.categories)
        when Category::PATTERN
          cat = @database.get_category(Category::PATTERN[path][:cat])
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
        elements = Utils.parse_form_data(form_data)
        errors = validate_post(elements)
        unless(errors == {})
          errmesg = ''
          errors.each do |type, message|
            errmesg << "#{type} error: #{message}\n" 
          end
          return HTTP::Response[409, errmesg.chomp]
        else
          @database.insert(elements[:title], elements[:slug], elements[:desc], elements[:body], elements[:category])
          @rss_feed.update(@database)
          return HTTP::Response[201, elements[:slug], "Location" => "/#{elements[:slug]}"]
        end
      end

      def post_admin_login(form_data, ip)
        unless(@ip_login_attempts[ip] >= 3)
          @ip_login_attempts[ip] += 1
          password = Utils.parse_form_data(form_data)[:password]
          if(password == ENV['blogapp_author_password'])
            @ip_login_attempts[ip] = 0
            return AdminSession.login_request(ip)
          end
        end
        return HTTP::Response[401, ""]
      end

      # PUT processors
      def put_updated_blogpost(form_data, admin)
        unless(admin)
          return Renderer.render_403(admin, true)
        end
        elements = Utils.parse_form_data(form_data)
        @database.update(elements[:slug], elements[:body])
        @rss_feed.update(@database)
        return HTTP::Response.redirect(elements[:slug])
      end

      # DELETE processors
      def delete_blogpost(form_data, admin)
        unless(admin)
          return Renderer.render_403(admin, true)
        end
        elements = Utils.parse_form_data(form_data)
        @database.delete(elements[:slug])
        @rss_feed.update(@database)
        return HTTP::Response.redirect('/')
      end

      # Data fetchers
      def fetch_archive
        archive = {}
        @database.recent_posts(65536).each do |post|
          year, month = post[:post_timestamp].year, post[:post_timestamp].strftime("%B").to_sym
          archive[year] ||= {}
          archive[year][month] ||= []
          archive[year][month] << post
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
