require 'socket'

s = TCPSocket.new 'localhost', 2345
@data = "12345678901234567890"
@lenght = @data.size
s.puts "set 2 15 300 #{@lenght}\r\n"
s.puts "#{@data} \r\n"
s.close
