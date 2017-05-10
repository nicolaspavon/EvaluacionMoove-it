require_relative 'memory'

MEMORY = Memory.new
MEMORY.start

class Memcached
  attr_accessor :response, :multiple_response

  def work(sentence, data, type)
    reset
    if type == "storage"
      @command = sentence.split(" ")[0].gsub(" ",'')
      @key = sentence.split(" ")[1].gsub(" ",'')
      @flags = sentence.split(" ")[2].gsub(" ",'')
      @exptime = sentence.split(" ")[3].gsub(" ",'')
      @bytes = sentence.split(" ")[4].gsub(" ",'')
      @cas_unique = sentence.split(" ")[5].gsub(" ",'') if @command == "cas"

      parameter_validation(@flags, @exptime, @bytes, "0") if ["set", "add", "replace"].include?(@command)
      parameter_validation(@flags, @exptime, @bytes, @cas_unique) if @command == "cas"
      error_manager("CLIENT_ERROR <Missing key>\r\n") if @key.empty?

    elsif type == "retrieval"
      @command = sentence.split(" ")[0].gsub(" ",'')
      if ["get", "gets"].include?(@command)
        @command, *@keys = sentence.split(/ /)
        @keys.delete("")
        error_manager("CLIENT_ERROR <Missing key>\r\n") if @keys.empty? == true
        @keys.each do |key|
        end
      end
    end

    MEMORY.exp_manager

    if @error == false
      set(@key, @flags, @exptime, @bytes, data)                if @command == "set"
      add(@key, @flags, @exptime, @bytes, data)                if @command == "add"
      replace(@key, @flags, @exptime, @bytes, data)            if @command == "replace"
      cas(@key, @flags, @exptime, @bytes, @cas_unique, data)   if @command == "cas"
      append(@key, data)                                       if @command == "append"
      m_prepend(@key, data)                                    if @command == "prepend"
      get(@keys)                                               if @command == "get"
      m_gets(@keys)                                            if @command == "gets"
      stats                                                    if @command == "stats"
    end
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

  def cas(key, flags, exptime, bytes, cas_unique, datablock)

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
    @multiple_response = MEMORY.get_all_keys
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
