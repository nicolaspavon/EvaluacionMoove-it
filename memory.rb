require_relative 'database'
require_relative 'memory_manager'
class Memory
  DATABASE_MANAGER = Database_Manager.new
  MEMORY_MANAGER = Memory_manager.new
  MEMORY_AMMOUNT = 50
  attr_accessor :key_data, :m_response

  def start
    @memory_used = 0
    DATABASE_MANAGER.start
    MEMORY_MANAGER.start(self)

    @key_flags = Hash.new
    @key_exptime = Hash.new
    @key_bytes = Hash.new
    @key_data = Hash.new
    @key_cas_unique = Hash.new

    @cas_token_array = Array.new

    @m_response = "nothing"
    @m_multiple_response = Array.new

    @new_cas_unique = ""
  end

  def exp_manager
    MEMORY_MANAGER.exp_manager(@key_exptime)
  end

  def set_key(key, flags, exptime, bytes, data)
    DATABASE_MANAGER.over_write(key, flags, exptime, bytes, data)
    save_in_memory(key, flags, exptime, bytes, data)
  end

  def generate_cas_token
    puts "generating cas token:"
    if @cas_token_array.index("") == nil
      @new_cas_unique = ((@cas_token_array.last.to_i) +1)
      @cas_token_array << @new_cas_unique
    else
      index = @cas_token_array.index("")
      @new_cas_unique = ((@cas_token_array[(@cas_token_array.index("")-1).to_i].to_i) +1)
      @cas_token_array[index] << @new_cas_unique
    end
    puts @new_cas_unique
  end

  def delete_cas_token(cas)
    @cas_token_array.delete("#{cas}")
    @new_cas_unique = ""
  end

  def get_key(key)
    if @key_data.has_key?(key)
      puts "#FROM MEMORY- loaded from memory: Key: #{key} Flags: #{@key_flags[key]} Exptime: #{@key_exptime[key]} Bytes: #{@key_bytes[key]}"
      puts "Data: #{@key_data[key]}"
      sentence = "VALUE #{key} #{@key_flags[key]} #{@key_bytes[key]}\r\n#{@key_data[key]}\r\n"
    else
      sentence = load_from_db(key)
    end
    sentence
  end

  def load_from_db(key)
    @data_from_db = DATABASE_MANAGER.load(key)
    if @data_from_db == nil
      puts "#FROM MEMORY- no data hold for this key"
      dbsentence = "CLIENT_ERROR <There's no data for this key>\r\n"
    else
      @key = @data_from_db.split(" ")[0]
      @flags = @data_from_db.split(" ")[1]
      @exptime = @data_from_db.split(" ")[2]
      @bytes = @data_from_db.split(" ")[3]
      @data = @data_from_db.split(" ", 5)[4]
      save_in_memory(@key, @flags, @exptime, @bytes, @data)
      puts "#FROM MEMORY- loaded from database: Key: #{@key} Flags: #{@flags} Exptime: #{@exptime} Bytes: #{@bytes}"
      dbsentence = "VALUE #{@key} #{@flags} #{@bytes}\r\n#{@data}\r\n"
    end
    dbsentence
  end

  def get_all_keys
    @key_data.each {|key, value| @m_multiple_response << "Key: #{key}, |Data: #{@key_data[key]}, Flags: #{@key_flags[key]}, |Exptime: #{@key_exptime[key]}, |Bytes: #{@key_bytes[key]}, |castoken: #{@key_cas_unique[key]}"}
    @m_multiple_response
  end

  def delete_key(key)
    puts "#FROM MEMORY- deleted key #{key}"
    @memory_used -= @key_bytes[key].to_i
    @key_flags.delete("#{key}")
    @key_exptime.delete("#{key}")
    @key_bytes.delete("#{key}")
    @key_data.delete("#{key}")
    puts "deleting this cas key:#{key} cas:#{@key_cas_unique[key]}"
    delete_cas_token(@key_cas_unique[key])
    @key_cas_unique.delete("#{key}")
  end

  def modify_data(key, flags, exptime, bytes, data, order)
    if @key_data.has_key?(key)
      data = "#{@key_data[key]}" + "#{data}" if order == "append"
      data = "#{data}" + "#{@key_data[key]}" if order == "m_prepend"
      @m_response = "STORED\r\n"
    else
      @data_from_db = DATABASE_MANAGER.load(key)
      if @data_from_db == nil
        puts "#FROM MEMORY- no data hold for this key"
      else
        data = "#{@data_from_db.split(" ")[4]}" + "#{data}" if order == "append"
        data = "#{data}" + "#{@data_from_db.split(" ")[4]}" if order == "m_prepend"
        @m_response = "STORED\r\n"
        puts "_________________________cuidado danger prekaka -#{data}-"
      end
    end
    DATABASE_MANAGER.over_write(key, flags, exptime, bytes, data)
    save_in_memory(key, flags, exptime, bytes, data)
  end

  def save_in_memory(key, flags, exptime, bytes, data)
    if (MEMORY_AMMOUNT > (@memory_used + bytes.to_i))
      @memory_used -= bytes.to_i if @key_data.has_key?(key)
      @key_flags[key] = flags
      @key_exptime[key] = exptime
      @key_bytes[key] = bytes
      @key_data[key] = data
      generate_cas_token
      @key_cas_unique[key] = @new_cas_unique
      @memory_used += bytes.to_i
      MEMORY_MANAGER.key_used(key)
      puts "#FROM MEMORY- data saved in MEMORY-"
      puts "#FROM MEMORY- memory used = #{@memory_used}"
    else
      delete_key(MEMORY_MANAGER.delete_LRU_key)
      @key_flags[key] = flags
      @key_exptime[key] = exptime
      @key_bytes[key] = bytes
      @key_data[key] = data
      generate_cas_token
      @key_cas_unique[key] = @new_cas_unique
      puts "generated and assigned cas token:#{@cas_unique_used[key]}-"
      @memory_used += bytes.to_i
      MEMORY_MANAGER.key_used(key)
      puts "#FROM MEMORY- data saved in MEMORY (DELETED LRU KEY)"
      puts "#FROM MEMORY- memory used = #{@memory_used}"
    end
  end

end
