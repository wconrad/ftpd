# frozen_string_literal: true

require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe DataServerFactory do

    it "creates a socket bound to localhost" do
      interface = "127.0.0.1"
      factory = DataServerFactory.new(interface)
      tcp_server = factory.make_tcp_server
      expect(tcp_server.addr[3]).to eq "127.0.0.1"
    end

    it "creates a socket bound to all interfaces" do
      interface = "0.0.0.0"
      factory = DataServerFactory.new(interface)
      tcp_server = factory.make_tcp_server
      expect(tcp_server.addr[3]).to eq "0.0.0.0"
    end

    it "creates a socket bound to an ephemeral port" do
      interface = "0.0.0.0"
      factory = DataServerFactory.new(interface)
      1000.times do
        tcp_server = factory.make_tcp_server
        port = tcp_server.addr[1]
        expect(port).to be_between(1024, 65535)
      end
    end

  end
end
