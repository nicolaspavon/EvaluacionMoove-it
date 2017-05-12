require_relative 'client'
require 'spec_helper'

describe Client do
   context "with valid imput" do
     it "should not save data" do
        @data = "information\r\n"
        @lenght = @data.gsub("\r\n",'').size
        @command = "set set1 257 #{@lenght}\r\n"
        client = Client.new
        client.storage(@command, @data)
        message = client.response
        expect(message).to eq "CLIENT_ERROR <parameter missing>\r\n"
     end
      it "should save data" do
         @data = "information\r\n"
         @lenght = @data.gsub("\r\n",'').size
         @command = "set set1 257 546 #{@lenght}\r\n"
         client = Client.new
         client.storage(@command, @data)
         message = client.response
         expect(message).to eq "STORED\r\n"
      end
      it "should get data" do
         @command = "get set1 \r\n"
         client = Client.new
         client.retrieval(@command)
         message = client.response
         expect(message).to eq "VALUE set1 257 11\r\ninformation\r\n"
      end
      it "should save data" do
         @data = "info\r\n"
         @lenght = @data.gsub("\r\n",'').size
         @command = "set set2 257 546 #{@lenght}\r\n"
         client = Client.new
         client.storage(@command, @data)
         message = client.response
         expect(message).to eq "STORED\r\n"
      end
      it "should get data" do
         @command = "get set2 \r\n"
         client = Client.new
         client.retrieval(@command)
         message = client.response
         expect(message).to eq "VALUE set2 257 4\r\ninfo\r\n"
      end
      it "should add data" do
         @data = "information add1\r\n"
         @lenght = @data.gsub("\r\n",'').size
         @command = "add add1 257 546 #{@lenght}\r\n"
         client = Client.new
         client.storage(@command, @data)
         message = client.response
         expect(message).to eq "STORED\r\n"
      end
      it "should get data" do
         @command = "get add1 \r\n"
         client = Client.new
         client.retrieval(@command)
         message = client.response
         expect(message).to eq "VALUE add1 257 16\r\ninformation add1\r\n"
      end
      it "should replace data" do
         @data = "information replace1\r\n"
         @lenght = @data.gsub("\r\n",'').size
         @command = "replace set1 257 546 #{@lenght}\r\n"
         client = Client.new
         client.storage(@command, @data)
         message = client.response
         expect(message).to eq "STORED\r\n"
      end
      it "should get data" do
         @command = "get set1 \r\n"
         client = Client.new
         client.retrieval(@command)
         message = client.response
         expect(message).to eq "VALUE set1 257 20\r\ninformation replace1\r\n"
      end
      it "should append data" do
         @data = "information append to set1\r\n"
         @lenght = @data.gsub("\r\n",'').size
         @command = "append set1 257 546 #{@lenght}\r\n"
         client = Client.new
         client.storage(@command, @data)
         message = client.response
         expect(message).to eq "STORED\r\n"
      end
      it "should get data" do
         @command = "get set1 \r\n"
         client = Client.new
         client.retrieval(@command)
         message = client.response
         expect(message).to eq "VALUE set1 257 47\r\ninformation replace1 information append to set1\r\n"
      end
      it "should prepend data" do
         @data = "information prepend to add1\r\n"
         @lenght = @data.gsub("\r\n",'').size
         @command = "prepend set1 257 546 #{@lenght}\r\n"
         client = Client.new
         client.storage(@command, @data)
         message = client.response
         expect(message).to eq "STORED\r\n"
      end
      it "should get data" do
         @command = "get set1 \r\n"
         client = Client.new
         client.retrieval(@command)
         message = client.response
         expect(message).to eq "VALUE set1 257 75\r\ninformation prepend to add1 information replace1 information append to set1\r\n"
      end
   end
end
