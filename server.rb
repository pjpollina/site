# The server program
# Just a prototype made from Frankenstining some tutorials online

require 'socket'
require 'mysql2'
require './blog_post.rb'

def http_404 # Static 404 response
  html = '<title>404 Error</title><h1>404 Not Found</h1>'
  "HTTP/1.1 404 Not Found\r\n" +
  "Content-Type: text/html\r\n" +
  "Content-Length: #{html.bytesize}\r\n" + 
  "Connection: close\r\n" +
  "\r\n" + html
end

def http_html(html) # Generates HTTP response for passed HTML content
  "HTTP/1.1 200 OK\r\n" +
  "Content-Type: text/html\r\n" +
  "Content-Length: #{html.bytesize}\r\n" +
  "Connection: close\r\n" +
  "\r\n" + html
end

PAGE_NAME = "PJ's Site" # The name of the site

server = TCPServer.new('localhost', 4000) # Creates a socket at localhost with the port 4000
database = Mysql2::Client.new(username: 'blog_server', password: '', database: 'blog') # Opens a connection with MySQL (MariaDB) database
loop do
  socket = server.accept  # Opens socket for data requests
  request = socket.gets   # Gets data sent to socket
  STDERR.puts request     # Prints recieved requests to console

  slug = request.split(' ')[1][1..-1] # Gets the slug of the post requested
  data = database.query("SELECT post_title, post_body, post_timestamp FROM posts WHERE post_slug='#{slug}'").first # Gets the post that matches the slug
  if(data.nil?)
    socket.print http_404 # Sends 404 error if post doesn't exist
  else
    post = BlogPost.new(data) # Creates an instance of BlogPost using the data retrived from the database
    response = post.render # Generates HTML code from the BlogPost object
    socket.print http_html(response) # Sends requested BlogPost HTML document back to client
  end
  socket.close # Ends the transaction
end
