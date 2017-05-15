require_relative '../database/database.rb'
require_relative '../database/false_database.rb'
require_relative 'memory_manager'
class Memory

  #------------------------------|
  FALSE_DB = false #--------------|Change to true in order to test memory without database|
  #------------------------------|

  if FALSE_DB == true
    DATABASE_MANAGER = False_Database_Manager.new
  else
    DATABASE_MANAGER = Database_Manager.new
  end

  MEMORY_MANAGER = Memory_manager.new
  MEMORY_AMMOUNT = 50
  attr_accessor :key_data, :m_response, :key_cas_unique, :key_bytes

  def start
    puts "MEMORY- STARTED"
    @memory_used = 0
    DATABASE_MANAGER.start
    MEMORY_MANAGER.start(self)

    @key_flags = Hash.new
    @key_exptime = Hash.new
    @key_bytes = Hash.new
    @key_data = Hash.new
    @key_cas_unique = Hash.new

    @cas_token_array = Array.new

    @m_response = ""
    @m_multiple_response = Array.new

    @new_cas_unique = ""
  end

  def exp_manager
    MEMORY_MANAGER.exp_manager(@key_exptime)
  end

  def set_key(key, flags, exptime, bytes, data)
    puts "Memory- setkey #{key}"
    DATABASE_MANAGER.over_write(key, flags, exptime, bytes, data)
    save_in_memory(key, flags, exptime, bytes, data)
  end

  def generate_cas_token
    if @cas_token_array.index("") == nil
      @new_cas_unique = ((@cas_token_array.last.to_i) +1)
      @cas_token_array << @new_cas_unique
    else
      index = @cas_token_array.index("")
      @new_cas_unique = ((@cas_token_array[(@cas_token_array.index("")-1).to_i].to_i) +1)
      @cas_token_array[index] << @new_cas_unique
    end
  end

  def delete_cas_key_hash(key)
    @key_cas_unique.delete(key)
  end

  def delete_cas_token(cas)
    @cas_token_array.delete("#{cas}")
    @new_cas_unique = ""
  end

  def get_key(key)
    puts "Memory- getkey #{key}"
    if @key_data.has_key?(key)
      sentence = "VALUE #{key} #{@key_flags[key]} #{@key_bytes[key]}\r\n#{@key_data[key]}\r\n"
    else
      if FALSE_DB == false
        sentence = load_from_db(key, "ncas")
      else
        sentence = "CLIENT_ERROR <There's no data for this key>\r\n"
      end
    end
    sentence
  end
  # repito codigo
  def gets_key(key)
    puts "Memory- getskey #{key}"
    if @key_data.has_key?(key)
      generate_cas_token
      @key_cas_unique[key] = @new_cas_unique
      sentence = "VALUE #{key} #{@key_flags[key]} #{@key_bytes[key]} #{@key_cas_unique[key]}\r\n#{@key_data[key]}\r\n"
    else
      if FALSE_DB == false
        sentence = load_from_db(key, "cas")
      else
        sentence = "CLIENT_ERROR <There's no data for this key>\r\n"
      end
    end
    sentence
  end

  def load_from_db(key, type)#-----------------------------------------------------
    @data_from_db = DATABASE_MANAGER.load(key)
    if @data_from_db == nil
      dbsentence = "CLIENT_ERROR <There's no data for this key>\r\n"
      puts "Memory- loadfrom db error"
    else
      puts "Memory- loadfrom db"
      @key = @data_from_db.split(" ")[0]
      @flags = @data_from_db.split(" ")[1]
      @exptime = @data_from_db.split(" ")[2]
      @bytes = @data_from_db.split(" ")[3]
      @data = @data_from_db.split(" ", 5)[4].strip
      save_in_memory(@key, @flags, @exptime, @bytes, @data)
      if type == "cas"
        generate_cas_token
        @key_cas_unique[key] = @new_cas_unique
        dbsentence = "VALUE #{@key} #{@flags} #{@bytes} #{@key_cas_unique[key]}\r\n#{@data}\r\n"
      else
        dbsentence = "VALUE #{@key} #{@flags} #{@bytes}\r\n#{@data}\r\n"
      end
    end
    dbsentence
  end

  def get_all_keys
    puts "Memory- load all keys"
    @key_data.each do |key, value|
      puts key
      if @key_cas_unique.has_key?(key)
        @m_multiple_response << "Key: #{key}, |Data: #{@key_data[key]}, Flags: #{@key_flags[key]}, |Exptime: #{@key_exptime[key]}, |Bytes: #{@key_bytes[key]}, |castoken: #{@key_cas_unique[key]}"
      else
        @m_multiple_response << "Key: #{key}, |Data: #{@key_data[key]}, Flags: #{@key_flags[key]}, |Exptime: #{@key_exptime[key]}, |Bytes: #{@key_bytes[key]}"
      end
    end
    @m_multiple_response
  end

  def delete_key(key)
    puts "Memory- deleted key #{key}"
    @memory_used -= @key_bytes[key].to_i
    @key_flags.delete("#{key}")
    @key_exptime.delete("#{key}")
    @key_bytes.delete("#{key}")
    @key_data.delete("#{key}")
    delete_cas_key_hash(key)
  end


  def modify_data(key, flags, exptime, bytes, data, order)
    @new_bytes = 0
    puts "Memory- modify data"
    if @key_data.has_key?(key)
      data = "#{@key_data[key]}" + " #{data}" if order == "append"
      data = "#{data}" + " #{@key_data[key]}" if order == "m_prepend"
      @m_response = "STORED\r\n"
      @new_bytes += (@key_bytes[key].to_i + bytes.to_i + 1)
      DATABASE_MANAGER.over_write(key, flags, exptime, @new_bytes, data)
      save_in_memory(key, flags, exptime, @new_bytes, data)
      puts "Memory- modified data saved"
    else
      if FALSE_DB == false
        @data_from_db = DATABASE_MANAGER.load(key) #-----------------------------------------------------
        if @data_from_db == nil
          @m_response = "NOT_STORED\r\n"
        else
          data = "#{@data_from_db.split(" ")[4]}" + " #{data}" if order == "append"
          data = "#{data}" + " #{@data_from_db.split(" ", 5)[4]}" if order == "m_prepend"
          @m_response = "STORED\r\n"
          @new_bytes += (@key_bytes[key].to_i + bytes.to_i + 1)
          DATABASE_MANAGER.over_write(key, flags, exptime, @new_bytes, data)
          save_in_memory(key, flags, exptime, @new_bytes, data)
          puts "Memory- modified data saved"
        end
      else
        puts "Memory- there's no such key in memory"
        @m_response = "NOT_STORED\r\n"
      end
    end
  end

  def save_in_memory(key, flags, exptime, bytes, data)
    puts "Memory- data saved in memory"
    if (MEMORY_AMMOUNT > (@memory_used + bytes.to_i))
      @memory_used -= @key_bytes[key].to_i if @key_data.has_key?(key)
      @key_flags[key] = flags
      @key_exptime[key] = exptime
      @key_bytes[key] = bytes
      @key_data[key] = data
      @memory_used += bytes.to_i
      delete_cas_key_hash(key)
      MEMORY_MANAGER.key_used(key)
    else
      delete_key(MEMORY_MANAGER.delete_LRU_key)
      @memory_used -= @key_bytes[key].to_i if @key_data.has_key?(key)
      @key_flags[key] = flags
      @key_exptime[key] = exptime
      @key_bytes[key] = bytes
      @key_data[key] = data
      delete_cas_key_hash(key)
      @memory_used += bytes.to_i
      MEMORY_MANAGER.key_used(key)
    end
  end

end
