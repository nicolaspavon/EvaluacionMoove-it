require_relative 'memory/memory.rb'

class Memcached
  puts "MEMCACHED- STARTED"
  MEMORY = Memory.new
  MEMORY.start
  attr_accessor :response, :multiple_response

  def work(sentence, data, type)
    puts "MEMCACHED- working..."

    reset
    parse_sentence(sentence, data, type)
    MEMORY.exp_manager

    if @error == false
      set(@key, @flags, @exptime, @bytes, data)                if @command == "set"
      add(@key, @flags, @exptime, @bytes, data)                if @command == "add"
      replace(@key, @flags, @exptime, @bytes, data)            if @command == "replace"
      cas(@key, @flags, @exptime, @bytes, @cas_unique, data)   if @command == "cas"
      append(@key, @flags, @exptime, @bytes, data)             if @command == "append"
      m_prepend(@key, @flags, @exptime, @bytes, data)          if @command == "prepend"
      get(@keys, "get")                                        if @command == "get"
      get(@keys, "m_gets")                                     if @command == "gets"
      stats                                                    if @command == "stats"
    end

  end

  def parse_sentence(sentence, data, type)
    if type == "storage"
      @command = sentence.split(" ")[0].gsub(" ",'')
      @key = sentence.split(" ")[1].gsub(" ",'')
      @flags = sentence.split(" ")[2].gsub(" ",'')
      @exptime = sentence.split(" ")[3].gsub(" ",'')
      @bytes = sentence.split(" ")[4].gsub(" ",'')
      @cas_unique = sentence.split(" ")[5].gsub(" ",'') if @command == "cas"
      check_for_errors(data)
    elsif type == "retrieval"
      @command = sentence.split(" ")[0].gsub(" ",'')
      if ["get", "gets"].include?(@command)
        @command, *@keys = sentence.split(/ /)
        @keys.delete("")
        error_manager("CLIENT_ERROR <Missing key>\r\n") if @keys.empty? == true
      end
    end
  end

  def check_for_errors(data)
    error_manager("CLIENT_ERROR <wrong data lenght>\r\n") if check_data_size(@bytes, data) == false

    parameter_validation(@flags, @exptime, @bytes, "0") if ["set", "add", "replace", "append", "prepend"].include?(@command)
    parameter_validation(@flags, @exptime, @bytes, @cas_unique) if @command == "cas"
    error_manager("CLIENT_ERROR <Missing key>\r\n") if @key.empty?
  end

  def reset
    @response = "nothing"
    @multiple_response = Array.new
    @keys = Array.new
    @error = false
    @command = ""
    @key = ""
    @flags = ""
    @exptime = ""
    @bytes = ""
    @cas_unique = ""
  end

  def check_data_size(bytes, data)
    data.size == bytes.to_i
  end

  def parameter_validation(flags, exptime, bytes, cas_unique)
    error_manager("CLIENT_ERROR <cas_unique must be numeric>\r\n") if check_parameter(cas_unique) == false
    error_manager("CLIENT_ERROR <flags must be numeric>\r\n") if check_parameter(flags) == false
    error_manager("CLIENT_ERROR <exptime must be numeric>\r\n") if check_parameter(exptime) == false
    error_manager("CLIENT_ERROR <bytes must be numeric>\r\n") if check_parameter(bytes) == false
  end

  def error_manager(error)
    @error = true
    @response = error
    @multiple_response[0] = error
  end

  def check_parameter(parameter)
    if parameter.nil? == false
      parameter.scan(/\D/).empty?
    else
      error_manager("CLIENT_ERROR <parameter missing>\r\n")
    end
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
    if MEMORY.key_cas_unique[key].to_s == "#{cas_unique}"
      self.set(key, flags, exptime, bytes, datablock)
    else
      @response = "EXISTS\r\n"
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
