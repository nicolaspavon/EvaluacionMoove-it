
class Database_Manager

  def start
    @database = File.open("database.txt", "a+")
    @load_array = Array.new
  end

  def load(key)
    File.open("database.txt", "r") do |file|
      file.any? do |line|
        @data = line if line.include?(key)
      end
    end
    @data
  end

  def check_repeated(key)
    File.readlines("database.txt").each_with_index do |line, line_num|
        @repeated_line = line_num if line.split(",")[0] == key
    end
    @repeated_line
  end

  def write(key, flags, exptime, bytes, data)
    if check_repeated(key) == nil
      File.open("database.txt", "a+") do |file|
        file << "#{key}, #{flags}, #{exptime}, #{bytes}, #{data}"
      end
      puts "#FROM DATABASE MANAGER: new line written: key#{key}"
    else
      puts "#FROM DATABASE MANAGER: key already used: key#{key}"
    end
  end

  def over_write(key, flags, exptime, bytes, data)
    @repeated_line = check_repeated(key)
    if @repeated_line != nil
      @load_array = File.readlines("database.txt")
      @load_array[@repeated_line] = "#{key}, #{flags}, #{exptime}, #{bytes}, #{data}" #------problema si el archivo es mas grande que la memoria (por guardar todo el archivo en el array)
      File.open("database.txt", "w") {|file| file.puts @load_array }
      puts "#FROM DATABASE MANAGER: replaced line #{@repeated_line}| Key: #{key}"
    else
      write(key, flags, exptime, bytes, data)
    end
  end
end
