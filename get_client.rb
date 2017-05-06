require 'socket'

s = TCPSocket.new 'localhost', 2345
@data = "very important sentence"
@lenght = @data.size
s.puts "get 2 3\r\n"
puts s.gets('\r\n')
# s.puts "@data \r\n"
s.close
