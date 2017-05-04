
class Memory_manager
  def start
    @key_order = Array.new
  end

  def key_used(key)
    @key_order.delete("#{key}") if @key_order.include?("#{key}")
    @key_order << key
    puts "#FROM MEMORY MANAGER- key added to key order"
  end

  def key_deleted()

  end

  def delete_LRU_key
    key = @key_order.at(0)
    @key_order.delete_at(0)
    puts "#FROM MEMORY MANAGER- deleted key #{key}"
    key
  end
end
