require_relative 'database'
require_relative 'memory'

DATABASE = Database.new
MEMORY = Memory.new
MEMORY.create_hashes

class Memcached
  def work(sentence, data)
    @command = sentence.split(" ")[0]
    @key = sentence.split(" ")[1]
    @flags = sentence.split(" ")[2]
    @exptime = sentence.split(" ")[3]
    @bytes = sentence.split(" ")[4]

    set(@key, @flags, @exptime, @bytes, data) if @command == "set"
    add(@key, data) if @command == "add"
    replace(@key, data) if @command == "replace"
    append(@key, data) if @command == "append"
    m_prepend(@key, data) if @command == "prepend"
    cas(@key, data) if @command == "cas"
    get(@key) if @command == "get"
    m_gets(@key) if @command == "gets"
  end
#----------------------------STORAGE COMMANDS------------------
  def set(key, flags, exptime, bytes, datablock)
    MEMORY.set_key(key, flags, exptime, bytes, datablock)
  end

  def add(key, datablock)

  end

  def replace(key, datablock)

  end

  def append(key, datablock)

  end

  def m_prepend(key, datablock)

  end

  def cas(key, datablock)

  end
#----------------------------RETRIEVAL COMMANDS ---------------------------
  def get(key)
    MEMORY.get_key(key)
  end

  def m_gets(key)

  end

end
