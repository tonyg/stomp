require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/client_shared_examples'

describe Stomp::Client do

  before(:each) do
    @mock_connection = mock('connection')
    Stomp::Connection.stub!(:new).and_return(@mock_connection)
  end

  describe "(created with no params)" do

    before(:each) do
      @client = Stomp::Client.new
    end

    it "should not return any errors" do
      lambda {
        @client = Stomp::Client.new
      }.should_not raise_error
    end

    it "should not return any errors when created with the open constructor" do
      lambda {
        @client = Stomp::Client.open
      }.should_not raise_error
    end

    it_should_behave_like "standard Client"

  end

  describe "(created with invalid params)" do

    it "should return ArgumentError if host is nil" do
      lambda {
        @client = Stomp::Client.new('login', 'passcode', nil)
      }.should raise_error
    end

    it "should return ArgumentError if host is empty" do
      lambda {
        @client = Stomp::Client.new('login', 'passcode', '')
      }.should raise_error
    end

    it "should return ArgumentError if port is nil" do
      lambda {
        @client = Stomp::Client.new('login', 'passcode', 'localhost', nil)
      }.should raise_error
    end

    it "should return ArgumentError if port is < 1" do
      lambda {
        @client = Stomp::Client.new('login', 'passcode', 'localhost', 0)
      }.should raise_error
    end

    it "should return ArgumentError if port is > 65535" do
      lambda {
        @client = Stomp::Client.new('login', 'passcode', 'localhost', 65536)
      }.should raise_error
    end

    it "should return ArgumentError if port is empty" do
      lambda {
        @client = Stomp::Client.new('login', 'passcode', 'localhost', '')
      }.should raise_error
    end

    it "should return ArgumentError if reliable is something other than true or false" do
      lambda {
        @client = Stomp::Client.new('login', 'passcode', 'localhost', '12345', 'foo')
      }.should raise_error
    end

  end


  describe "(created with positional params)" do

    before(:each) do
      @client = Stomp::Client.new('testlogin', 'testpassword', 'localhost', '12345', false)
    end

    it "should properly parse the URL provided" do
      @client.login.should eql('testlogin')
      @client.passcode.should eql('testpassword')
      @client.host.should eql('localhost')
      @client.port.should eql(12345)
      @client.reliable.should be_false
    end

    it_should_behave_like "standard Client"

  end

  describe "(created with non-authenticating stomp:// URL and non-TLD host)" do

    before(:each) do
      @client = Stomp::Client.new('stomp://foobar:12345')
    end

    it "should properly parse the URL provided" do
      @client.login.should eql('')
      @client.passcode.should eql('')
      @client.host.should eql('foobar')
      @client.port.should eql(12345)
      @client.reliable.should be_false
    end

    it_should_behave_like "standard Client"

  end

  describe "(created with authenticating stomp:// URL and non-TLD host)" do

    before(:each) do
      @client = Stomp::Client.new('stomp://testlogin:testpasscode@foobar:12345')
    end

    it "should properly parse the URL provided" do
      @client.login.should eql('testlogin')
      @client.passcode.should eql('testpasscode')
      @client.host.should eql('foobar')
      @client.port.should eql(12345)
      @client.reliable.should be_false
    end

    it_should_behave_like "standard Client"

  end

  describe "(created with non-authenticating stomp:// URL and TLD host)" do

    before(:each) do
      @client = Stomp::Client.new('stomp://host.foobar.com:12345')
    end

    after(:each) do
    end

    it "should properly parse the URL provided" do
      @client.login.should eql('')
      @client.passcode.should eql('')
      @client.host.should eql('host.foobar.com')
      @client.port.should eql(12345)
      @client.reliable.should be_false
    end

    it_should_behave_like "standard Client"

  end

  describe "(created with authenticating stomp:// URL and non-TLD host)" do

    before(:each) do
      @client = Stomp::Client.new('stomp://testlogin:testpasscode@host.foobar.com:12345')
    end

    it "should properly parse the URL provided" do
      @client.login.should eql('testlogin')
      @client.passcode.should eql('testpasscode')
      @client.host.should eql('host.foobar.com')
      @client.port.should eql(12345)
      @client.reliable.should be_false
    end

    it_should_behave_like "standard Client"

  end

end