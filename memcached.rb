require_relative 'memory'

MEMORY = Memory.new
MEMORY.start

class Memcached
  attr_accessor :response, :multiple_response

  def work(sentence, data, type)
    @response = "nothing"
    @multiple_response = Array.new
    @keys = Array.new
    @error = false
    if type == "storage"
      @command = sentence.split(" ")[0]
      @key = sentence.split(" ")[1]
      @flags = sentence.split(" ")[2]
      @exptime = sentence.split(" ")[3]
      @bytes = sentence.split(" ")[4]
    elsif type == "retrieval"
      @command, *@keys = sentence.split(/ /)
    end

    MEMORY.exp_manager
    if @error == false
      set(@key, @flags, @exptime, @bytes, data)     if @command == "set"
      add(@key, @flags, @exptime, @bytes, data)     if @command == "add"
      replace(@key, @flags, @exptime, @bytes, data) if @command == "replace"
      append(@key, data)                            if @command == "append"
      m_prepend(@key, data)                         if @command == "prepend"
      get(@keys)                                    if @command == "get"
      get(@keys)                                    if @command == "gets"
      stats                                         if @command == "stats"
    end
  end

#----------------------------STORAGE COMMANDS------------------
  def set(key, flags, exptime, bytes, datablock)
    MEMORY.set_key(key, flags, exptime, bytes, datablock)
    @response = "STORED\r\n"
  end

  def add(key, flags, exptime, bytes, datablock)
    if MEMORY.key_data.has_key?(key)
      puts "#FROM MEMCACHED- key #{key} already in use"
      @response = "NOT_STORED\r\n"
    else
      MEMORY.set_key(key, flags, exptime, bytes, datablock)
      @response = "STORED\r\n"
    end
  end

  def replace(key, flags, exptime, bytes, datablock)
    if MEMORY.key_data.has_key?(key)
      MEMORY.set_key(key, flags, exptime, bytes, datablock)
      @response = "STORED\r\n"
    else
      puts "#FROM MEMCACHED- no such key #{key} in use"
      @response = "NOT_STORED\r\n"
    end
  end

  def append(key, datablock)
    MEMORY.modify_data(key, flags, exptime, bytes, datablock, append)
    @response = MEMORY.m_response
  end

  def m_prepend(key, datablock)
    MEMORY.modify_data(key, flags, exptime, bytes, datablock, m_prepend)
    @response = MEMORY.m_response
  end
#----------------------------RETRIEVAL COMMANDS ---------------------------
  def stats
    puts "#FROM MEMCACHED- keys from memory"
    MEMORY.get_all_keys
  end

  def get(key)
    if key.is_a?(Array)
      key.each_with_index do |key, index|
        @multiple_response[index] = MEMORY.get_key(key)
      end
    else
      @multiple_response[0] = MEMORY.get_key(key)
    end
  end
end
