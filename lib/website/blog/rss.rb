# Class for blog's RSS feed

require 'website/template'

module Website
  module Blog
    class RSS
      TEMPLATE = Template.new('rss_feed.erb')

      def initialize(post_count: 5, feed_path: 'feed.rss')
        @post_count = post_count
        @feed_path  = feed_path
      end

      def update(database)
        WebFile.write(@feed_path, TEMPLATE.render(posts: database.recent_posts(@post_count)))
      end
    end
  end
end
