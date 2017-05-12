require 'socket'

class Client
  attr_accessor :response
  def storage(command, data)
    s = TCPSocket.new 'localhost', 2345
    s.puts "#{command}"
    s.puts "#{data}"
    @response = s.gets
    s.close
  end
  def retrieval(command)
    s = TCPSocket.new 'localhost', 2345
    s.puts "#{command}"
    @response = s.gets('\r\n')
    s.close
  end
end
