require_relative 'client'
require 'spec_helper'

describe Client do
    it "should storage" do
      @data = "example\r\n"
      @lenght = @data.gsub("\r\n",'').size
      @command = "command examplekey flags exptime #{@lenght} casunique(ifcas)\r\n"
      client = Client.new
      client.storage(@command, @data)
      message = client.response
      expect(message).to eq "\r\n"
    end

    it "should retrieval" do
      @command = "command examplekey \r\n"
      client = Client.new
      client.retrieval(@command)
      message = client.response
      expect(message).to eq "\r\n"
    end
end

# possible responses:
# "ERROR\r\n"
# "CLIENT_ERROR <error>\r\n"
# "SERVER_ERROR <error>\r\n"
# "STORED\r\n"
# "NOT_STORED\r\n"
# "EXISTS\r\n"
# "NOT_FOUND\r\n"

# example command
# @data = "example\r\n"
# @lenght = @data.gsub("\r\n",'').size
# @command = "set examplekey 0 999 #{@lenght}\r\n"
# or: @command = "cas examplekey 0 999 #{@lenght} 1 \r\n"
