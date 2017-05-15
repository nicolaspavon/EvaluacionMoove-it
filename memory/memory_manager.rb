
class Memory_manager
  def start(memory)
    puts "MEMORY-MANAGER- STARTED"
    @key_order = Array.new
    @key_last_time_used = Hash.new
    @ary = Hash.new
    @memory = memory
  end

  def key_used(key)
    @key_order.delete("#{key}") if @key_order.include?("#{key}")
    @key_order << key
    @key_last_time_used[key] = Time.now.to_i
    puts "MEMORY-MANAGER- key added to key order"
  end

  def exp_manager(key_exptime)
    key_exptime.each do |key, value|
      if (@key_last_time_used[key].to_i + value.to_i) < Time.now.to_i
        @memory.delete_key(key)
        @key_order.delete(key)
        puts "MEMORY-MANAGER- deleted expired key"
      end
    end
  end

  def delete_LRU_key
    puts "MEMORY-MANAGER- deleted lru key"
    key = @key_order.at(0)
    @key_order.delete_at(0)
    key
  end
end
