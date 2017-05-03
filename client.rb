require 'socket'

s = TCPSocket.new 'localhost', 2345
@data = "very important sentence"
@lenght = @data.size
s.puts "get 12 \r\n"
# s.puts "@data \r\n"
s.close
