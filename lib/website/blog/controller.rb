# Class that controls all blog features of the site

module Website
  module Blog
    class Controller
      MONTH_PATTERN = PathPattern.new("/archive/:year/:month")

      def initialize
        @database = Database.new
        @rss_feed = RSS.new
        @blacklist = Blacklist.new
        @rss_feed.update(@database)
      end

      def respond(path, admin)
        case path
        when '/'
          Renderer.render_page("Home", :homepage, admin, false, recent_posts: @database.recent_posts(6))
        when '/archive'
          Renderer.render_page("Archive", :archive, admin, false, archives: @database.get_full_archive, categories: @database.categories, counts: @database.get_category_counts)
        when '/new_post'
          Renderer.render_page("New Post", :new_post, admin, true, categories: @database.categories)
        when Category::PATTERN
          cat = @database.get_category(Category::PATTERN[path][:cat])
          unless(cat.nil?)
            Renderer.render_page(cat.name, :post_feed, admin, false, title: "Posts in category #{cat.name}", posts: cat.posts.reverse_each)
          else
            Renderer.render_error_page(404, admin)
          end
        when MONTH_PATTERN
          data = MONTH_PATTERN[path]
          unless(data.nil?)
            posts = @database.month_posts(Date::MONTHNAMES.index(data[:month].capitalize), data[:year])
            unless(posts.count == 0)
              period = "#{data[:month].capitalize} #{data[:year]}"
              Renderer.render_page("Archive for #{period}", :post_feed, admin, false, title: "Posts from #{period}", posts: posts)
            else
              Renderer.render_error_page(404, admin)
            end
          else
            Renderer.render_error_page(404, admin)
          end
        else
          post = @database.get_post(path[1..-1].chomp('?edit=true'))
          Renderer.render_post_page(post, admin, path.end_with?('?edit=true'))
        end
      end

      # POST processors
      def post_new_blogpost(form_data, admin)
        unless(admin)
          return Errors.render_error(403)
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
        unless(@blacklist.banned?(ip))
          @blacklist.add_attempt(ip)
          password = Utils.parse_form_data(form_data)[:password]
          if(password == ENV['blogapp_author_password'])
            @blacklist.clear_attempts(ip)
            return AdminSession.login_request(ip)
          elsif(@blacklist.banned?(ip))
            @blacklist.blacklist_ip(ip)
            puts "IP address #{ip} has been blacklisted"
          end
        end
        return HTTP::Response[401, ""]
      end

      # PUT processors
      def put_updated_blogpost(form_data, admin)
        unless(admin)
          return Errors.render_error(403)
        end
        elements = Utils.parse_form_data(form_data)
        @database.update(elements[:slug], elements[:body])
        @rss_feed.update(@database)
        return HTTP::Response.redirect(elements[:slug])
      end

      # DELETE processors
      def delete_blogpost(form_data, admin)
        unless(admin)
          return Errors.render_error(403)
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
