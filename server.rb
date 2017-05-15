require 'socket'
require_relative 'memcached'
MEMCACHED = Memcached.new
SEMAPHORE = Mutex.new

class Server
  puts "SERVER- STARTED"
  def initialize
    server = TCPServer.new('localhost', 2345)
    loop do
      Thread.fork(server.accept) do |socket|
        puts "SERVER- socket accepted --------------------------------------------------"
        SEMAPHORE.synchronize{
          use_memcached(socket)
          socket.close
          puts "SERVER- SOCKET END"
        }
      end
    end
  end

  def use_memcached(socket)
    request_line = socket.gets.strip
    request_line = request_line.squeeze(" ")
    if ["set", "add", "replace", "append", "prepend", "cas"].include?(request_line.split(" ")[0])
      data = socket.gets.strip
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
      socket.puts "CLIENT_ERROR <wrong command>\r\n"
    end
  end
end
Server.new
