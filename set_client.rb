require 'socket'

class SetClient
  def setkey1
    s = TCPSocket.new 'localhost', 2345
    @data = "nueva data"
    @lenght = @data.size
    s.puts "set 6 257 546 #{@lenght}\r\n"
    s.puts "#{@data} \r\n"
    @response = s.gets
    puts @response
    s.close
  end
  def setkey2
    s = TCPSocket.new 'localhost', 2345
    @data = "asda sasfacartvbr key 2"
    @lenght = @data.size
    s.puts "set 2 #{@lenght}\r\n"
    s.puts "#{@data} \r\n"
    @response = s.gets
    puts @response
    s.close
  end
  def setkey3
    s = TCPSocket.new 'localhost', 2345
    @data = "datakey3"
    @lenght = @data.size
    s.puts "set 3 5 10 #{@lenght}\r\n"
    s.puts "#{@data} \r\n"
    @response = s.gets
    puts @response
    s.close
  end
  def addkey3
    s = TCPSocket.new 'localhost', 2345
    @data = "adddatakey3"
    @lenght = @data.size
    s.puts "add 3 3 20 #{@lenght}\r\n"
    s.puts "#{@data} \r\n"
    @response = s.gets
    puts @response
    s.close
  end
  def addkey4
    s = TCPSocket.new 'localhost', 2345
    @data = "adddatakey4"
    @lenght = @data.size
    s.puts "add 32 25 #{@lenght}\r\n"
    s.puts "#{@data} \r\n"
    @response = s.gets
    puts @response
    s.close
  end
  def replacekey2
    s = TCPSocket.new 'localhost', 2345
    @data = "replaced key 2"
    @lenght = @data.size
    s.puts "replace 2 32 53 #{@lenght}\r\n"
    s.puts "#{@data} \r\n"
    @response = s.gets
    puts @response
    s.close
  end
end
client = SetClient.new
client.setkey1
# client.setkey2
# client.setkey3
# client.addkey3
# client.addkey4
# client.replacekey2
