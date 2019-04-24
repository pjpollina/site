# Helper module that renders pages

require 'website/errors'
require 'website/template'

module Website
  module Blog
    module Renderer
      extend self

      LAYOUT = Template.load_layout('layout.erb')

      VIEWS = {
        homepage:  Template.load_view('homepage.erb'),
        archive:   Template.load_view('archive.erb'),
        new_post:  Template.load_view('new_post.erb'),
        post:      Template.load_view('post.erb'),
        edit_post: Template.load_view('edit_post.erb'),
        post_feed: Template.load_view('post_feed.erb')
      }

      # Part Renderers
      def render_layout(name, admin)
        LAYOUT[page_name: name, admin: admin] { yield }
      end

      def render_view(view, locals)
        VIEWS[view][locals]
      end

      # Page Renderers
      def render_page(name, view, admin, admin_locked, locals)
        if(admin_locked && !admin)
          render_error_page(403, admin)
        else
          page = render_layout(name, admin) do
            render_view(view, locals)
          end
          HTTP::Response.html_response(page)
        end
      end

      def render_post_page(post, admin, edit=false)
        if(post.nil?)
          render_error_page(404, admin)
        else
          name, view = ((edit) ? ["Editing Post #{post.title}", :edit_post] : [post.title, :post])
          render_page(name, view, admin, edit, post: post, admin: admin)
        end
      end

      def render_static_page(path, name, admin)
        page = render_layout(name, admin) do
          WebFile.read(path)
        end
        HTTP::Response.html_response(page)
      end

      def render_error_page(code, admin)
        page = render_layout(Errors[code].status_message, admin) do
          Errors.render_error(code)
        end
        HTTP::Response.html_response(page, code)
      end
    end
  end
end
