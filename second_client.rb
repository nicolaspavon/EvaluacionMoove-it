require 'socket'

s = TCPSocket.new 'localhost', 2345
@data = "very important sentence"
@lenght = @data.size
s.puts "set 12 4568 15 #{@lenght}\r\n"
s.puts "#{@data} \r\n"
s.close
