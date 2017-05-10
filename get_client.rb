require 'socket'

s = TCPSocket.new 'localhost', 2345
@data = "very important sentence"
@lenght = @data.size
s.puts "stats \r\n"
puts s.gets('\r\n')
s.close
