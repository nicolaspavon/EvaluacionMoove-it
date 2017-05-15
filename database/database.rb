
class Database_Manager

  def start
    puts "DATABASE- STARTED"
    @database = File.open("Database/database.txt", "a+")
    @database.close
    @load_array = Array.new
  end

  def load(key)
    @data = nil
    puts "DATABASE- loading key #{key}"
    sleep 0.5
    File.open("Database/database.txt", "r") do |file|
      file.any? do |line|
        @data = line if line.split(" ")[0] == key
      end
    end
    @data
  end

  def check_repeated(key)
    sleep 0.5
    File.readlines("Database/database.txt").each_with_index do |line, line_num|
        @repeated_line = line_num if line.split(" ")[0] == key
    end
  end

  def write(key, flags, exptime, bytes, data)
    sleep 0.5
    puts "DATABASE- write key #{key}"
    File.open("Database/database.txt", 'a') {|file| file.puts "#{key} #{flags} #{exptime} #{bytes} #{data}"}
  end

  def over_write(key, flags, exptime, bytes, data)
    sleep 0.5
    @repeated_line = nil
    check_repeated(key)
    if @repeated_line != nil
      puts "DATABASE- overwrite key #{key}"
      @load_array = File.readlines("Database/database.txt")
      @load_array[@repeated_line] = "#{key} #{flags} #{exptime} #{bytes} #{data}" #------problema si el archivo es mas grande que la memoria (por guardar todo el archivo en el array)
      File.open("Database/database.txt", "w") {|file| file.puts @load_array }
    else
      write(key, flags, exptime, bytes, data)
    end
  end
end
