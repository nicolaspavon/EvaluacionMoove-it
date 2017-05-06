
class Memory_manager
  def start(memory)
    @key_order = Array.new
    @key_last_time_used = Hash.new
    @ary = Hash.new
    @memory = memory
  end

  def key_used(key)
    @key_order.delete("#{key}") if @key_order.include?("#{key}")
    @key_order << key
    @key_last_time_used[key] = Time.now.to_i
    puts "#FROM MEMORY MANAGER- key added to key order"
  end


  def exp_manager(key_exptime)
    key_exptime.each do |key, value|
      @memory.delete_key(key) if @key_last_time_used[key].to_i + value.to_i < Time.now.to_i
    end
  end

  def delete_LRU_key
    key = @key_order.at(0)
    @key_order.delete_at(0)
    puts "#FROM MEMORY MANAGER- deleted key #{key}"
    key
  end
end
