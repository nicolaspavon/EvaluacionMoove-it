
class Database_Manager

  def start
    @database = File.open("database.txt", "a+")
  end

  def load(key)
    File.open("database.txt", "r") do |file|
      file.any? do |line|
        puts "#FROM DATABASE- loaded from DATABASE"
        puts "#{line}" if line.include?(key)
      end
    end
  end

  def check_repeated(key)
    File.readlines("database.txt").each_with_index do |line, line_num|
        @repeated_line = line_num if line.split(",")[0] == key
    end
    puts "#FROM DATABASE MANAGER: repeated line = #{@repeated_line}"
    @repeated_line
  end

  def write(key, flags, exptime, bytes, data)
    if check_repeated(key) == nil
      File.open("database.txt", "a+") do |file|
        file << "#{key}, #{flags}, #{exptime}, #{bytes}, #{data}"
      end
      puts "#FROM DATABASE MANAGER: new line written #{key}"
    else
      puts "#FROM DATABASE MANAGER: key already used #{key}"
    end
  end

  def over_write(key, flags, exptime, bytes, data)
    if check_repeated(key) != nil
      File.open("database.txt", "a+") do |file|
        file.each_with_index do |line, line_num|
          if line_num == check_repeated(key)
            line << "#{key}, #{flags}, #{exptime}, #{bytes}, #{data}"
            puts "#FROM DATABASE MANAGER: replaced line:"
            puts "line = #{line_num}"
            puts "key = #{key}"
          end
        end
      end
    else
      write(key, flags, exptime, bytes, data)
    end
  end
  #
  # def modify_data (key, bytes, data)
  #   if check_repeated(key) != nil
  #     File.open("database.txt", "a+") do |file|
  #       file.each_with_index do |line, line_num|
  #         if line_num == check_repeated(key)
  #           old_flags = line.split(",")[1]
  #           old_exptime = line.split(",")[2]
  #           line << "#{key}, #{old_flags}, #{old_exptime}, #{bytes}, #{data}"
  #           puts "#FROM DATABASE MANAGER: modified data from:"
  #           puts "line = #{line_num}"
  #           puts "key = #{key}"
  #         end
  #       end
  #     end
  #   else
  #     puts "#FROM DATABASE MANAGER: failed to modify data:"
  #     puts "no matching key: #{key}"
  #   end
  # end
  #
  # def modify_flags (key, flags)
  #   if check_repeated(key) != nil
  #     File.open("database.txt", "a+") do |file|
  #       file.each_with_index do |line, line_num|
  #         if line_num == check_repeated(key)
  #           old_data = line.split(",")[4]
  #           old_bytes = line.split(",")[3]
  #           old_exptime = line.split(",")[2]
  #           line << "#{key}, #{flags}, #{old_exptime}, #{old_bytes}, #{old_data}"
  #           puts "#FROM DATABASE MANAGER: modified data from:"
  #           puts "line = #{line_num}"
  #           puts "key = #{key}"
  #         end
  #       end
  #     end
  #   else
  #     puts "#FROM DATABASE MANAGER: failed to modify flags:"
  #     puts "no matching key: #{key}"
  #   end
  # end
  #
  # def modify_exptime (key, exptime)
  #   if check_repeated(key) != nil
  #     File.open("database.txt", "a+") do |file|
  #       file.each_with_index do |line, line_num|
  #         if line_num == check_repeated(key)
  #           old_flags = line.split(",")[1]
  #           old_data = line.split(",")[4]
  #           old_bytes = line.split(",")[3]
  #           line << "#{key}, #{old_flags}, #{exptime}, #{old_bytes}, #{old_data}"
  #           puts "#FROM DATABASE MANAGER: modified exptime from:"
  #           puts "line = #{line_num}"
  #           puts "key = #{key}"
  #         end
  #       end
  #     end
  #   else
  #     puts "#FROM DATABASE MANAGER: failed to modify exptime:"
  #     puts "no matching key: #{key}"
  #   end
  # end

end
