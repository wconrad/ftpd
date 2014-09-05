require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe Protocols do

    # A fake server that returns a connected server-side socket.

    class TestServer

      # The socket upon which the server is listening

      attr_reader :listening_socket

      # Returns the connected server-side socket

      attr_reader :connected_socket

      # @param bind_address [String] The address to which to bind the
      #   server socket.
      # @param connect_address [String] The address to which the
      #   client socket should connect.

      def initialize(bind_address, connect_address)
        queue = Queue.new
        @listening_socket = TCPServer.new(bind_address, 0)
        port = @listening_socket.addr[1]
        Thread.new do
          queue.enq @listening_socket.accept
        end
        client_socket = TCPSocket.new(connect_address, port)
        @connected_socket = queue.deq
      end

    end

    context 'IPV4 server' do

      let(:bind_address) {'127.0.0.1'}
      let(:connect_address) {'127.0.0.1'}
      let(:connected_socket) do
        TestServer.new(bind_address, connect_address).connected_socket
      end
      subject(:protocols) {Protocols.new(connected_socket)}

      it 'should support IPV4' do
        expect(protocols.supports_protocol?(Protocols::IPV4)).to be_truthy
      end

      it 'should not support IPV6' do
        expect(protocols.supports_protocol?(Protocols::IPV6)).to be_falsey
      end

      it 'should list the supported protocols' do
        expect(protocols.protocol_codes).to eq [
          Protocols::IPV4,
        ]
      end

    end

    context 'IPV6 server, IPV6 connection' do

      let(:bind_address) {'::1'}
      let(:connect_address) {'::1'}
      let(:connected_socket) do
        TestServer.new(bind_address, connect_address).connected_socket
      end
      subject(:protocols) {Protocols.new(connected_socket)}

      it 'should not support IPV4' do
        expect(protocols.supports_protocol?(Protocols::IPV4)).to be_falsey
      end

      it 'should support IPV6' do
        expect(protocols.supports_protocol?(Protocols::IPV6)).to be_truthy
      end

      it 'should list the supported protocols' do
        expect(protocols.protocol_codes).to eq [
          Protocols::IPV6,
        ]
      end

    end

    context 'wildcard server, IPV4 connection' do

      let(:bind_address) {'::'}
      let(:connect_address) {'127.0.0.1'}
      let(:connected_socket) do
        TestServer.new(bind_address, connect_address).connected_socket
      end
      subject(:protocols) {Protocols.new(connected_socket)}

      it 'should support IPV4' do
        expect(protocols.supports_protocol?(Protocols::IPV4)).to be_truthy
      end

      it 'should support IPV6' do
        expect(protocols.supports_protocol?(Protocols::IPV6)).to be_truthy
      end

      it 'should list the supported protocols' do
        expect(protocols.protocol_codes).to eq [
          Protocols::IPV4,
          Protocols::IPV6,
        ]
      end

    end

    context 'wildcard server, IPV6 connection' do

      let(:bind_address) {'::'}
      let(:connect_address) {'::1'}
      let(:connected_socket) do
        TestServer.new(bind_address, connect_address).connected_socket
      end
      subject(:protocols) {Protocols.new(connected_socket)}

      it 'should support IPV4' do
        expect(protocols.supports_protocol?(Protocols::IPV4)).to be_truthy
      end

      it 'should support IPV6' do
        expect(protocols.supports_protocol?(Protocols::IPV6)).to be_truthy
      end

      it 'should list the supported protocols' do
        expect(protocols.protocol_codes).to eq [
          Protocols::IPV4,
          Protocols::IPV6,
        ]
      end

    end

  end
end
