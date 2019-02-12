# Helper module that renders pages

require 'page_builder'

module Website
  module Blog
    module Renderer
      LAYOUT = PageBuilder::Layout.new('layout.erb')

      VIEWS = {
        homepage:  PageBuilder::View.new('homepage.erb'),
        archive:   PageBuilder::View.new('archive.erb'),
        new_post:  PageBuilder::View.new('new_post.erb'),
        post:      PageBuilder::View.new('post.erb'),
        edit_post: PageBuilder::View.new('edit_post.erb'),
        category:  PageBuilder::View.new('category.erb')
      }

      # Page Renderers
      def self.render_page(name, view, admin, admin_locked, locals)
        if(admin_locked && !admin)
          render_403(admin)
        else
          page = LAYOUT[name, admin] do
            VIEWS[view][locals]
          end
          HTTPServer.html_response(page)
        end
      end

      def self.render_post_page(post, admin, edit=false)
        if(post.nil?)
          render_404(admin)
        else
          name, view = ((edit) ? ["Editing Post #{post.title}", :edit_post] : [post.title, :post])
          render_page(name, view, admin, edit, post: post, admin: admin)
        end
      end

      def self.render_403(admin, simple=false)
        page = File.read HTTPServer.web_file("403.html")
        unless(simple)
          page = LAYOUT["403", admin] { page }
        end
        HTTPServer.html_response(page, 403)
      end

      def self.render_404(admin)
        page = LAYOUT["404", admin] do
          File.read HTTPServer.web_file("404.html")
        end
        HTTPServer.html_response(page, 404)
      end
    end
  end
end
