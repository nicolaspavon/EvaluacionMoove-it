require 'socket'

s = TCPSocket.new 'localhost', 2345
@data = "not"
@lenght = @data.size
s.puts "set 768 25 164 #{@lenght}\r\n"
s.puts "#{@data} \r\n"
s.close
