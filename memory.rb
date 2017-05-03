
class Memory

  def create_hashes
    @key_flags = Hash.new
    @key_exptime = Hash.new
    @key_bytes = Hash.new
    @key_data = Hash.new
  end

  def set_key(key, flags, exptime, bytes, data)
    @key_flags[key] = flags
    @key_exptime[key] = exptime
    @key_bytes[key] = bytes
    @key_data[key] = data
    puts "data saved in memorial"
  end

  def get_key(key)
    puts @key_data[key] + "Flags: " + @key_flags[key] + " Exptime: " + @key_exptime[key] + " Bytes: " + @key_bytes[key]
  end

end
