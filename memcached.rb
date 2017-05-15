require_relative 'memory/memory.rb'
require_relative 'command_analyzer'

class Memcached
  puts "MEMCACHED- STARTED"
  MEMORY = Memory.new
  ANALYZER = Command_analyzer.new
  MEMORY.start
  attr_accessor :response, :multiple_response

  def work(sentence, data, type)
    @multiple_response = Array.new
    puts "MEMCACHED- working..."
    @response = ""
    MEMORY.exp_manager
    ANALYZER.analyze(sentence, data, type, self)
  end

  def error_manager(error)
    puts "MEMCACHED- error= #{error}"
    ANALYZER.error = true
    @response = error
    @multiple_response[0] = error
  end

#----------------------------STORAGE COMMANDS------------------
  def set(key, flags, exptime, bytes, datablock)
    puts "MEMCACHED- command set executed"
    MEMORY.set_key(key, flags, exptime, bytes, datablock)
    @response = "STORED\r\n"
  end

  def add(key, flags, exptime, bytes, datablock)
    puts "MEMCACHED- command add executed"
    if MEMORY.key_data.has_key?(key)
      @response = "NOT_STORED\r\n"
    else
      MEMORY.set_key(key, flags, exptime, bytes, datablock)
      @response = "STORED\r\n"
    end
  end

  def replace(key, flags, exptime, bytes, datablock)
    puts "MEMCACHED- command replace executed"
    if MEMORY.key_data.has_key?(key)
      MEMORY.set_key(key, flags, exptime, bytes, datablock)
      @response = "STORED\r\n"
    else
      @response = "NOT_STORED\r\n"
    end
  end

  def cas(key, flags, exptime, bytes, cas_unique, datablock)
    puts "MEMCACHED- command cas executed"
    if MEMORY.key_data.has_key?(key)
      if MEMORY.key_cas_unique[key].to_s == "#{cas_unique}"
        self.set(key, flags, exptime, bytes, datablock)
      else
        @response = "EXISTS\r\n"
      end
    else
      @response = "CLIENT_ERROR <There's no data for this key>\r\n"
    end
  end

  def append(key, flags, exptime, bytes, datablock)
    puts "MEMCACHED- command append executed"
    MEMORY.modify_data(key, flags, exptime, bytes, datablock, "append")
    @response = MEMORY.m_response
  end

  def m_prepend(key, flags, exptime, bytes, datablock)
    puts "MEMCACHED- command prepend executed"
    MEMORY.modify_data(key, flags, exptime, bytes, datablock, "m_prepend")
    @response = MEMORY.m_response
  end
#----------------------------RETRIEVAL COMMANDS ---------------------------
  def stats
    puts "MEMCACHED- command stats executed"
    @multiple_response = MEMORY.get_all_keys
  end

  def get(key, type)
    puts "MEMCACHED- command #{type} executed"
    if key.is_a?(Array)
      key.each_with_index do |key, index|
        @multiple_response[index] = MEMORY.get_key(key) if type == "get"
        @multiple_response[index] = MEMORY.gets_key(key) if type == "m_gets"
      end
    else
      @multiple_response[0] = MEMORY.get_key(key) if type == "get"
      @multiple_response[0] = MEMORY.gets_key(key) if type == "m_gets"
    end
  end
end
