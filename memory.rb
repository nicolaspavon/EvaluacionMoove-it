require_relative 'database'
require_relative 'memory_manager'
class Memory
  DATABASE_MANAGER = Database_Manager.new
  MEMORY_MANAGER = Memory_manager.new
  MEMORY_AMMOUNT = 50
  attr_accessor :key_data

  def start
    @memory_used = 0
    DATABASE_MANAGER.start
    MEMORY_MANAGER.start

    @key_flags = Hash.new
    @key_exptime = Hash.new
    @key_bytes = Hash.new
    @key_data = Hash.new

  end

  def exp_manager

  end

  def set_key(key, flags, exptime, bytes, data)
    DATABASE_MANAGER.over_write(key, flags, exptime, bytes, data)

    if (MEMORY_AMMOUNT > (@memory_used + bytes.to_i))
      @memory_used -= bytes.to_i if @key_data.has_key?(key)
      @key_flags[key] = flags
      @key_exptime[key] = exptime
      @key_bytes[key] = bytes
      @key_data[key] = data
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
      @memory_used += bytes.to_i
      MEMORY_MANAGER.key_used(key)
      puts "#FROM MEMORY- data saved in MEMORY (DELETED LRU KEY)"
      puts "#FROM MEMORY- memory used = #{@memory_used}"
    end
  end

  def get_key(key)
    if @key_data.has_key?(key)
      puts @key_data[key] + "Flags: " + @key_flags[key] + " Exptime: " + @key_exptime[key] + " Bytes: " + @key_bytes[key]
    else
      DATABASE_MANAGER.load(key)
    end
  end

  def get_all_keys
    @key_data.each {|key, value| puts "Key: #{key}, |Data: #{@key_data[key]}", "Flags: #{@key_flags[key]}, |Exptime: #{@key_exptime[key]}, |Bytes: #{@key_bytes[key]}"}
  end

  def delete_key(key)
    puts "#FROM MEMORY- deleted key #{key}"
    @memory_used -= @key_bytes[key].to_i
    @key_flags.delete("#{key}")
    @key_exptime.delete("#{key}")
    @key_bytes.delete("#{key}")
    @key_data.delete("#{key}")
  end

end
