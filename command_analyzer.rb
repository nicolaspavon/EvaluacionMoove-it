
class Command_analyzer
  attr_accessor :error
  def analyze(sentence, data, type, memcached)
    @memcached = memcached
    @keys = Array.new
    @error = false
    check_for_missing_parameters(sentence)

    if @error == false
      parse_retrieval_sentence(sentence) if type == "retrieval"
      parse_storage_sentence(sentence) if type == "storage"

      @cas_unique = "0" if @command != "cas"
      parameter_validation(@flags, @exptime, @bytes, @cas_unique) if type == "storage"
      check_data_size(@bytes, data) if type == "storage"
      retrieval_parameter_validation if type == "retrieval"
    end

    if @error == false
      @memcached.set(@key, @flags, @exptime, @bytes, data)                if @command == "set"
      @memcached.add(@key, @flags, @exptime, @bytes, data)                if @command == "add"
      @memcached.replace(@key, @flags, @exptime, @bytes, data)            if @command == "replace"
      @memcached.cas(@key, @flags, @exptime, @bytes, @cas_unique, data)   if @command == "cas"
      @memcached.append(@key, @flags, @exptime, @bytes, data)             if @command == "append"
      @memcached.m_prepend(@key, @flags, @exptime, @bytes, data)          if @command == "prepend"
      @memcached.get(@keys, "get")                                        if @command == "get"
      @memcached.get(@keys, "m_gets")                                     if @command == "gets"
      @memcached.stats                                                    if @command == "stats"
    end

  end

  def check_for_missing_parameters(sentence)
    @command = sentence.split(" ")[0]
    if @command == "cas"
      @memcached.error_manager("CLIENT_ERROR <missing parameter>\r\n") if (sentence.scan(/\w+/)).length < 6
      @memcached.error_manager("CLIENT_ERROR <unexpected parameter>\r\n") if (sentence.scan(/\w+/)).length > 6

    elsif ["set", "add", "replace", "append", "prepend"].include?(@command)
      @memcached.error_manager("CLIENT_ERROR <missing parameter>\r\n") if (sentence.scan(/\w+/)).length < 5
      @memcached.error_manager("CLIENT_ERROR <unexpected parameter>\r\n") if (sentence.scan(/\w+/)).length > 5
    end
  end

  def parameter_validation(flags, exptime, bytes, cas_unique)
    @memcached.error_manager("CLIENT_ERROR <cas_unique must be numeric>\r\n") if check_parameter(cas_unique) == false
    @memcached.error_manager("CLIENT_ERROR <flags must be numeric>\r\n") if check_parameter(flags) == false
    @memcached.error_manager("CLIENT_ERROR <exptime must be numeric>\r\n") if check_parameter(exptime) == false
    @memcached.error_manager("CLIENT_ERROR <bytes must be numeric>\r\n") if check_parameter(bytes) == false
  end

  def check_parameter(parameter)
      parameter.scan(/\D/).empty?
  end

  def check_data_size(bytes, data)
    @memcached.error_manager("CLIENT_ERROR <the data length isn't equal to #bytes>\r\n") if data.size.to_i != bytes.to_i
  end

  def parse_retrieval_sentence(sentence)
    @command = sentence.split(" ")[0]
    if ["get", "gets"].include?(@command)
      @command, *@keys = sentence.split(/ /)
      @keys.delete("")
    end
  end

  def retrieval_parameter_validation
    if @command != "stats"
      @memcached.error_manager("CLIENT_ERROR <missing key argument>\r\n") if @keys.empty? == true
    end
  end

  def parse_storage_sentence(sentence)
    @command = sentence.split(" ")[0]
    @key = sentence.split(" ")[1]
    @flags = sentence.split(" ")[2]
    @exptime = sentence.split(" ")[3]
    @bytes = sentence.split(" ")[4]
    @cas_unique = sentence.split(" ")[5] if @command == "cas"
  end
end
