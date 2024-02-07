# frozen_string_literal: true

require_relative "../testlib/network"

module Ftpd
  describe Protocols do

    extend TestLib::Network

    def self.if_stack_supports_ipv6
      if ipv6_supported?
        return yield
      else
        if !@ipv6_warning_issued
          warn "Stack does not support IPV6; skipping some tests"
          @ipv6_warning_issued = true
        end
      end
    end

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

        _client_socket = TCPSocket.new(connect_address, port)
        @connected_socket = queue.deq
      end

      def ipv6_dual_stack?
        @connected_socket.local_address.ipv6? &&
        !@connected_socket.getsockopt(
          Socket::IPPROTO_IPV6,
          Socket::IPV6_V6ONLY
        ).bool
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

    if_stack_supports_ipv6 do
      context 'IPV6 server, IPV6 connection' do

        let(:bind_address) {'::1'}
        let(:connect_address) {'::1'}
        let(:test_server) {TestServer.new(bind_address, connect_address)}
        let(:connected_socket) {test_server.connected_socket}
        subject(:protocols) {Protocols.new(connected_socket)}

        it 'should not support IPV4' do
          expect(protocols.supports_protocol?(Protocols::IPV4)).to be(test_server.ipv6_dual_stack?)
        end

        it 'should support IPV6' do
          expect(protocols.supports_protocol?(Protocols::IPV6)).to be_truthy
        end

        it 'should list the supported protocols' do
          expect(protocols.protocol_codes).to eq [
                                                (Protocols::IPV4 if test_server.ipv6_dual_stack?),
                                                Protocols::IPV6
                                              ].compact
        end

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

    if_stack_supports_ipv6 do
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
end
