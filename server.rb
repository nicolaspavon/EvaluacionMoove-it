require 'socket'
require_relative 'memcached'
MEMCACHED = Memcached.new

class Server
  server = TCPServer.new('localhost', 2345)
  loop do
    socket       = server.accept
    request_line = socket.gets
    if ["set", "add", "replace", "append", "prepend", "cas"].include?(request_line.split(" ")[0])
      data = socket.gets
      MEMCACHED.work(request_line, data)
    elsif ["get", "gets"].include?(request_line.split(" ")[0])
      data = nil
      MEMCACHED.work(request_line, data)
      socket.close
    else
      message = "Error\r\n"
      socket.print "HTTP/1.1 404 Not Found\r\n" + "Content-Type: text/plain\r\n" + "Content-Length: #{message.size}\r\n" + "Connection: close\r\n"
      socket.print "\r\n"
      socket.print message
    end
    socket.close
  end
end
