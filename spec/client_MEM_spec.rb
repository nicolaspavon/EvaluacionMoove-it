require_relative 'client'
require 'spec_helper'

describe Client do
  #----------------------------------------------------------------------------------------------------context-change
  context "with too many users at the same time" do
    it "should not crash" do
      @data = "information\r\n"
      @lenght = @data.gsub("\r\n",'').size
      @command = "  set set1    257 546 #{@lenght}   \r\n"
      @user_quantity = Array.new(10)
      @user_quantity.each_with_index do |client, index|
        @user_quantity[index] = Thread.new do
          client = Client.new
          client.storage(@command, @data)
          message = client.response
          expect(message).to eq "STORED\r\n"
        end
      end
      @user_quantity.each do |thread|
        thread.join
      end
    end
  end
#----------------------------------------------------------------------------------------------------context-change
  context "with invalid imput" do
     it "should not save data without key" do
        @data = "information\r\n"
        @lenght = @data.gsub("\r\n",'').size
        @command = "set 257 546 #{@lenght}\r\n"
        client = Client.new
        client.storage(@command, @data)
        message = client.response
        expect(message).to eq "CLIENT_ERROR <missing parameter>\r\n"
     end

     it "should not save data with wrong # of bytes" do
        @data = "information\r\n"
        @lenght = @data.gsub("\r\n",'').size
        @command = "set set1 257 546 54\r\n"
        client = Client.new
        client.storage(@command, @data)
        message = client.response
        expect(message).to eq "CLIENT_ERROR <the data length isn't equal to #bytes>\r\n"
     end

     it "should not save data without bytes" do
        @data = "information\r\n"
        @lenght = @data.gsub("\r\n",'').size
        @command = "set set1 257 546\r\n"
        client = Client.new
        client.storage(@command, @data)
        message = client.response
        expect(message).to eq "CLIENT_ERROR <missing parameter>\r\n"
     end

     it "should not add data without flags" do
        @data = "information add1\r\n"
        @lenght = @data.gsub("\r\n",'').size
        @command = "add add1 546 #{@lenght}\r\n"
        client = Client.new
        client.storage(@command, @data)
        message = client.response
        expect(message).to eq "CLIENT_ERROR <missing parameter>\r\n"
     end

     it "should not replace data without exp time" do
        @data = "information replace1\r\n"
        @lenght = @data.gsub("\r\n",'').size
        @command = "replace set1 257 #{@lenght}\r\n"
        client = Client.new
        client.storage(@command, @data)
        message = client.response
        expect(message).to eq "CLIENT_ERROR <missing parameter>\r\n"
     end

     it "should not append data with not numeric parameter" do
        @data = "information append to set1\r\n"
        @lenght = @data.gsub("\r\n",'').size
        @command = "append set1 257 5asd4 #{@lenght}\r\n"
        client = Client.new
        client.storage(@command, @data)
        message = client.response
        expect(message).to eq "CLIENT_ERROR <exptime must be numeric>\r\n"
     end

     it "should not prepend data with more parameters than expected" do
        @data = "information prepend to add1\r\n"
        @lenght = @data.gsub("\r\n",'').size
        @command = "prepend set1 257 546 454 684 #{@lenght}\r\n"
        client = Client.new
        client.storage(@command, @data)
        message = client.response
        expect(message).to eq "CLIENT_ERROR <unexpected parameter>\r\n"
     end

      it "should not get cas number because key doesnt exists" do
         @command = "gets 99999 \r\n"
         client = Client.new
         client.retrieval(@command)
         message = client.response
         expect(message).to eq "CLIENT_ERROR <There's no data for this key>\r\n"
       end

       it "should not save data using cas because wrong cas number" do

         # SET KEY
         @data = "trywrongcas\r\n"
         @lenght = @data.gsub("\r\n",'').size
         @command = "set trywrongcas 257 555 #{@lenght}\r\n"
         client = Client.new
         client.storage(@command, @data)
         message = client.response
         expect(message).to eq "STORED\r\n"

         #  gets key
         @command = "gets trywrongcas \r\n"
         client = Client.new
         client.retrieval(@command)
         message = client.response
         expect(message).to eq "VALUE trywrongcas 257 11 1\r\ntrywrongcas\r\n"

         @data = "NEW INFO CAS\r\n"
         @lenght = @data.gsub("\r\n",'').size
         @command = "cas trywrongcas 257 555 #{@lenght} 6\r\n"
         client = Client.new
         client.storage(@command, @data)
         message = client.response
         expect(message).to eq "EXISTS\r\n"
       end
    end
#----------------------------------------------------------------------------------------------------context-change
  context "with valid imput" do
     it "should save data" do
        @data = "information\r\n"
        @lenght = @data.gsub("\r\n",'').size
        @command = "  set set1    257 546 #{@lenght}   \r\n"
        client = Client.new
        client.storage(@command, @data)
        message = client.response
        expect(message).to eq "STORED\r\n"
     end

    it "should add data to a unused key" do
       @data = "information add1\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "add add1 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "STORED\r\n"
    end

    it "should not add data with a used key" do
       @data = "new information add1\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "add add1 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "NOT_STORED\r\n"
    end

    #
    it "should replace existent data" do
       @data = "information replace1\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "replace set1 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "STORED\r\n"
    end

    it "should not replace nonexistent data" do
       @data = "nonexistent data\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "replace nonexistentREP 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "NOT_STORED\r\n"
    end

    it "should append data to an existent key" do
       @data = "information append to set1\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "append set1 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "STORED\r\n"
    end

    it "should not append data to a nonexistent key" do
       @data = "information append to set1\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "append nonexistentAPP 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "NOT_STORED\r\n"
    end

    it "should prepend data to an existent key" do
       @data = "information prepend to add1\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "prepend add1 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "NOT_STORED\r\n"
    end

    it "should not prepend data to a nonexistent key" do
       @data = "information prepend to add1\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "prepend nonexistentPREP 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "NOT_STORED\r\n"
    end

    it "should get data" do
       @command = "get set1 \r\n"
       client = Client.new
       client.retrieval(@command)
       message = client.response
       expect(message).to eq "VALUE set1 257 47\r\ninformation replace1 information append to set1\r\n"
    end

    it "should not get nonexistent data" do
       @command = "get nonexistent \r\n"
       client = Client.new
       client.retrieval(@command)
       message = client.response
       expect(message).to eq "CLIENT_ERROR <There's no data for this key>\r\n"
    end

    it "should get cas number" do
      @command = "gets set1 \r\n"
      client = Client.new
      client.retrieval(@command)
      message = client.response
      expect(message).to eq "VALUE set1 257 47 2\r\ninformation replace1 information append to set1\r\n"
    end

    it "should not get cas number of a nonexistent key" do
       @command = "gets nonexistent \r\n"
       client = Client.new
       client.retrieval(@command)
       message = client.response
       expect(message).to eq "CLIENT_ERROR <There's no data for this key>\r\n"
     end

    it "should save data using cas" do
       @data = "information\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "  cas set1    257 546 #{@lenght} 2  \r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "STORED\r\n"
    end

    it "should not save data to a nonexistent key using cas" do
       @data = "information\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "  cas nonexistent    257 546 #{@lenght} 2  \r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "CLIENT_ERROR <There's no data for this key>\r\n"
    end

    it "expired data should not be in memory" do
       @data = "information\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "  set exp1    257 5 #{@lenght}   \r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "STORED\r\n"

       sleep 6 #espero a que pase el tiempo de expiracion (5seg)
       #PIDO TODAS LAS KEYS
       @command = "stats\r\n"
       client = Client.new
       client.retrieval(@command)
       message = client.response
       expect(message).to eq "Key: set1, |Data: information, Flags: 257, |Exptime: 546, |Bytes: 11\n"
    end

    it "should get these keys" do
       @command = "get set1 add1 exp1 \r\n"
       client = Client.new
       client.retrieval(@command)
       message = client.response
       expect(message).to eq "VALUE set1 257 11\r\ninformation\r\nCLIENT_ERROR <There's no data for this key>\r\nCLIENT_ERROR <There's no data for this key>\r\n"
    end
  end
#----------------------------------------------------------------------------------------------------context-change
#----------------------------------------------------------------------------------------------------context-change
  context "should eliminate LRU key (keylru) (if mem ammount == 50 bytes)" do
    it "should add a key, which will be used after te lru key" do
       @data = "10bytesdat\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "add NOTlrukey 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "STORED\r\n"

       #command stats in order to see keys in memory
       @command = "stats\r\n"
       client = Client.new
       client.retrieval(@command)
       #PARA CORROBORAR ESTO, VER DATOS MOSTRADOS POR EL SERVIDOR---------IMPORTANTE-------
    end

    it "should save lru key" do
       @data = "20-bytes-data-------\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "set keylru 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "STORED\r\n"

       #command stats in order to see keys in memory
       @command = "stats\r\n"
       client = Client.new
       client.retrieval(@command)
    end

    it "should save a random key (not the lru key)"do
      @data = "20-bytes-data-------\r\n"
      @lenght = @data.gsub("\r\n",'').size
      @command = "set randomkey 257 546 #{@lenght}\r\n"
      client = Client.new
      client.storage(@command, @data)
      message = client.response
      expect(message).to eq "STORED\r\n"

      #command stats in order to see keys in memory
      @command = "stats\r\n"
      client = Client.new
      client.retrieval(@command)
    end

    it "should replace the (NOTlrukey) added at the begining, (so the lru key will be the really lru key)" do
       @data = "10bytes---\r\n"
       @lenght = @data.gsub("\r\n",'').size
       @command = "replace NOTlrukey 257 546 #{@lenght}\r\n"
       client = Client.new
       client.storage(@command, @data)
       message = client.response
       expect(message).to eq "STORED\r\n"

       #command stats in order to see keys in memory
       @command = "stats\r\n"
       client = Client.new
       client.retrieval(@command)
    end

    it "will save new data, deleting the LRU key"do
      @data = "30-bytes-data-----------------\r\n"
      @lenght = @data.gsub("\r\n",'').size
      @command = "set newkey 257 546 #{@lenght}\r\n"
      client = Client.new
      client.storage(@command, @data)
      message = client.response
      expect(message).to eq "STORED\r\n"

      #command stats in order to see keys in memory
      @command = "stats\r\n"
      client = Client.new
      client.retrieval(@command)
    end
  end
end
