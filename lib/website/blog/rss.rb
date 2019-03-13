# Class for blog's RSS feed

module Website
  module Blog
    class RSS
      TEMPLATE = Tilt::ERBTemplate.new(Utils.web_file('templates/feed.erb'))

      def initialize(post_count: 5, feed_path: 'feed.rss')
        @post_count = post_count
        @feed_path  = feed_path
      end

      def update(database)
        File.write(Utils.web_file(@feed_path), TEMPLATE.render(nil, posts: database.recent_posts(@post_count)))
      end
    end
  end
end
