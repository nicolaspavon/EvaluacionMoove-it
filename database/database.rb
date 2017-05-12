
class Database_Manager

  def start
    puts "DATABASE- STARTED"
    @database = File.open("Database/database.txt", "a+")
    @load_array = Array.new
  end

  def load(key)
    puts "DATABASE- load key #{key}"
    File.open("Database/database.txt", "r") do |file|
      file.any? do |line|
        @data = line if line.include?(key)#-----------------------------malo
      end
    end
    @data
  end

  def check_repeated(key)
    File.readlines("Database/database.txt").each_with_index do |line, line_num|
        @repeated_line = line_num if line.split(",")[0] == key
    end
    @repeated_line
  end

  def write(key, flags, exptime, bytes, data)
    puts "DATABASE- write key #{key}"
    File.open("Database/database.txt", "a+") do |file|
      file << "#{key}, #{flags}, #{exptime}, #{bytes}, #{data}\r\n"
    end
  end

  def over_write(key, flags, exptime, bytes, data)
    puts "DATABASE- overwrite key #{key}"
    @repeated_line = check_repeated(key)
    if @repeated_line != nil
      @load_array = File.readlines("Database/database.txt")
      @load_array[@repeated_line] = "#{key}, #{flags}, #{exptime}, #{bytes}, #{data}" #------problema si el archivo es mas grande que la memoria (por guardar todo el archivo en el array)
      File.open("Database/database.txt", "w") {|file| file.puts @load_array }
    else
      write(key, flags, exptime, bytes, data)
    end
  end
end
