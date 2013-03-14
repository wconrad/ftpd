require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd

  describe ConnectionTracker do

    before(:all) do
      Thread.abort_on_exception = true
    end    

    # Create a mock socket with the given peer address

    def socket_bound_to(source_ip)
      socket = mock TCPSocket
      peeraddr = Socket.pack_sockaddr_in(0, source_ip)
      socket.stub :getpeername => peeraddr
      socket
    end

    # Since the connection tracker only keeps track of a connection
    # until the block to which it yields returns, we need a way to
    # keep a block active.

    class Connector

      def initialize(connection_tracker)
        @connection_tracker = connection_tracker
        @connected = Queue.new
        @disconnect = Queue.new
        @disconnected = Queue.new
      end

      # Start tracking a connection.  Does not return until it is
      # being tracked.

      def connect(socket)
        Thread.new do
          @connection_tracker.track(socket) do
            @connected.enq :go
            @disconnect.deq
          end
          @disconnected.enq :go
        end
        @connected.deq
      end

      # Stop tracking a connection.  Does not return until it is no
      # longer tracked.

      def disconnect
        @disconnect.enq :go
        @disconnected.deq
      end

    end

    let(:connector) {Connector.new(connection_tracker)}
    subject(:connection_tracker) {ConnectionTracker.new}

    describe '#connections' do

      let(:socket) {socket_bound_to('127.0.0.1')}

      it 'should track the total number of connection' do
        connection_tracker.connections.should == 0
        connector.connect socket
        connection_tracker.connections.should == 1
        connector.disconnect
        connection_tracker.connections.should == 0
      end

    end

    describe '#connections_for' do

      it 'should track the number of connections for an ip' do
        socket1 = socket_bound_to('127.0.0.1')
        socket2 = socket_bound_to('127.0.0.2')
        connection_tracker.connections_for(socket1).should == 0
        connection_tracker.connections_for(socket2).should == 0
        connector.connect socket1
        connection_tracker.connections_for(socket1).should == 1
        connection_tracker.connections_for(socket2).should == 0
        connector.disconnect
        connection_tracker.connections_for(socket1).should == 0
        connection_tracker.connections_for(socket2).should == 0
      end

    end

  end

end
