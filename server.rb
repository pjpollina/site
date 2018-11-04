# The server program
# Just a prototype made from Frankenstining some tutorials online

require 'socket'
require 'erb'
require 'mysql2'
require './blog_post.rb'

PAGE_NAME = "PJ's Site" # The name of the site

server = TCPServer.new('localhost', 4000) # Creates a socket at localhost with the port 4000
database = Mysql2::Client.new(username: 'blog_server', password: '', database: 'blog') # Opens a connection with MySQL (MariaDB) database
template = ERB.new(File.read './templates/blog_post.erb') # Creates an ERB template from templates/blog_post.erb
loop do
  socket = server.accept  # Opens socket for data requests
  request = socket.gets   # Gets data sent to socket
  STDERR.puts request     # Prints recieved requests to console

  slug = request.split(' ')[1][1..-1] # Gets the slug of the post requested
  data = database.query("SELECT post_title, post_body, post_timestamp FROM posts WHERE post_slug='#{slug}'").first # Gets the post that matches the slug
  post = BlogPost.new(data || {}) # Creates an instance of BlogPost using the data retrived from the database
  response = post.render(template) # Generates HTML code from the BlogPost object

  socket.print "HTTP/1.1 200 OK\r\n" + # Sends the requested page data back to the client
               "Content-Type: text/html\r\n" +
               "Content-Length: #{response.bytesize}\r\n" +
               "Connection: close\r\n"
  socket.print "\r\n"
  socket.print response
  socket.close # Ends the transaction
end
