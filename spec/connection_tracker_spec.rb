require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd

  describe ConnectionTracker do

    before(:all) do
      Thread.abort_on_exception = true
    end    

    # Create a mock socket with the given peer address

    def socket_bound_to(source_ip)
      socket = double TCPSocket
      peeraddr = Socket.pack_sockaddr_in(0, source_ip)
      allow(socket).to receive(:getpeername) {peeraddr}
      socket
    end

    # Since the connection tracker only keeps track of a connection
    # until the block to which it yields returns, we need a way to
    # keep a block active.

    class Connector

      # Enable the rspec expect syntax in this class.
      # This uses an internal API of rspec-mock.
      # See: http://stackoverflow.com/q/25692786/238886
      RSpec::Mocks::Syntax.enable_expect self

      def initialize(connection_tracker)
        @connection_tracker = connection_tracker
        @tracked = Queue.new
        @end_session = Queue.new
        @session_ended = Queue.new
      end

      # Start tracking a connection.  Does not return until it is
      # being tracked.

      def start_session(socket)
        Thread.new do
          @connection_tracker.track(socket) do
            @tracked.enq :go
            command = @end_session.deq
            if command == :close
              allow(socket).to receive(:getpeername)
              .and_raise(RuntimeError, "Socket closed")
            end
          end
          @session_ended.enq :go
        end
        @tracked.deq
      end

      # Stop tracking a connection.  Does not return until it is no
      # longer tracked.

      def end_session(command = :normally)
        @end_session.enq command
        @session_ended.deq
      end

    end

    let(:connector) {Connector.new(connection_tracker)}
    subject(:connection_tracker) {ConnectionTracker.new}

    describe '#connections' do

      let(:socket) {socket_bound_to('127.0.0.1')}

      context '(session ends normally)' do

        it 'should track the total number of connection' do
          expect(connection_tracker.connections).to eq 0
          connector.start_session socket
          expect(connection_tracker.connections).to eq 1
          connector.end_session
          expect(connection_tracker.connections).to eq 0
        end

      end

      context '(socket disconnected during session)' do

        it 'should track the total number of connection' do
          expect(connection_tracker.connections).to eq 0
          connector.start_session socket
          expect(connection_tracker.connections).to eq 1
          connector.end_session :close
          expect(connection_tracker.connections).to eq 0
        end

      end

    end

    describe '#connections_for' do

      it 'should track the number of connections for an ip' do
        socket1 = socket_bound_to('127.0.0.1')
        socket2 = socket_bound_to('127.0.0.2')
        expect(connection_tracker.connections_for(socket1)).to eq 0
        expect(connection_tracker.connections_for(socket2)).to eq 0
        connector.start_session socket1
        expect(connection_tracker.connections_for(socket1)).to eq 1
        expect(connection_tracker.connections_for(socket2)).to eq 0
        connector.end_session
        expect(connection_tracker.connections_for(socket1)).to eq 0
        expect(connection_tracker.connections_for(socket2)).to eq 0
      end

    end

    describe '#known_ip_count' do

      let(:socket) {socket_bound_to('127.0.0.1')}

      it 'should forget about an IP that has no connection' do
        expect(connection_tracker.known_ip_count).to eq 0
        connector.start_session socket
        expect(connection_tracker.known_ip_count).to eq 1
        connector.end_session
        expect(connection_tracker.known_ip_count).to eq 0
      end

    end

  end

end
