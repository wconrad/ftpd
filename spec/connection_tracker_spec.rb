require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd

  describe ConnectionTracker do

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
    let(:socket) {mock TCPSocket}
    subject(:connection_tracker) {ConnectionTracker.new}

    it 'should track the total number of connection' do
      connection_tracker.connections.should == 0
      connector.connect socket
      connection_tracker.connections.should == 1
      connector.disconnect
      connection_tracker.connections.should == 0
    end

  end

end
