# frozen_string_literal: true

require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe DataServerFactory do

    it "creates a socket bound to 127.0.0.1" do
      factory = DataServerFactory.make("127.0.0.1", nil)
      tcp_server = factory.make_tcp_server
      expect(tcp_server.addr[3]).to eq "127.0.0.1"
    end

    it "creates a socket bound to 127.0.0.2" do
      factory = DataServerFactory.make("127.0.0.2", nil)
      tcp_server = factory.make_tcp_server
      expect(tcp_server.addr[3]).to eq "127.0.0.2"
    end

    context "with no port range" do

      it "creates a socket bound to an ephemeral port" do
        interface = "0.0.0.0"
        factory = DataServerFactory.make(interface, nil)
        ports = (1..10).map do
          tcp_server = factory.make_tcp_server
          begin
            tcp_server.addr[1]
          ensure
            tcp_server.close
          end
        end
        expect(ports.uniq.size).to be > 1
        ports.each do |port|
          expect(port).to be_between(1024, 65535)
        end
      end

    end

    context "with a port range" do

      let(:interface) { "127.0.0.1" }
      
      def get_unused_port
        server = TCPServer.new(interface, 0)
        port = server.addr[1]
        server.close
        port
      end

      def use_port(port)
        server = TCPServer.new(interface, port)
        begin
          yield
        ensure
          server.close
        end
      end

      it "creates a socket bound to an ephemeral port" do
        ports = (1..10).map { get_unused_port }
        factory = DataServerFactory.make(interface, ports)
        10.times do
          tcp_server = factory.make_tcp_server
          begin
            port = tcp_server.addr[1]
            expect(ports).to include(port)
          ensure
            tcp_server.close
          end
        end
      end

      it "skips a port that is already in use" do
        ports = (1..2).map { get_unused_port }
        use_port(ports[0]) do
          factory = DataServerFactory.make(interface, ports)
          10.times do
            tcp_server = factory.make_tcp_server
            begin
              port = tcp_server.addr[1]
              expect(port).to eq ports[1]
            ensure
              tcp_server.close
            end
          end
        end
      end

      it "uses a random ephemeral port when all configured ports are in use" do
        ports = [ get_unused_port ]
        use_port(ports[0]) do
          factory = DataServerFactory.make(interface, ports)
          tcp_server = factory.make_tcp_server
          port = tcp_server.addr[1]
          expect(port).to_not eq ports[0]
        end
      end

    end

  end
end
