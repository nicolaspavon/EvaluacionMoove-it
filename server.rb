require 'socket'
require_relative 'memcached'
MEMCACHED = Memcached.new

class Server
  server = TCPServer.new('localhost', 2345)
  loop do
    socket       = server.accept
    request_line = socket.gets.gsub("\r\n",'')
    if ["set", "add", "replace", "append", "prepend", "cas"].include?(request_line.split(" ")[0])
      data = socket.gets.gsub(" \r\n",'')
      MEMCACHED.work(request_line, data, "storage")
      socket.puts MEMCACHED.response
    elsif ["get", "gets", "stats"].include?(request_line.split(" ")[0])
      data = nil
      MEMCACHED.work(request_line, data, "retrieval")
      MEMCACHED.multiple_response.each do |response|
        socket.puts response
      end
      socket.close
    else
      socket.print "CLIENT_ERROR <wrong command>\r\n"
    end
    socket.close
  end
end
