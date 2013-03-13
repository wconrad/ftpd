require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd

  describe ConnectionThrottle do

    let(:connections) {0}
    let(:connection_tracker) do
      mock ConnectionTracker, :connections => connections
    end
    subject(:connection_throttle) do
      ConnectionThrottle.new(connection_tracker)
    end

    it 'should have defaults' do
      connection_throttle.max_connections.should == 100
    end

    describe '#allow?' do
      
      let(:max_connections) {50}
      let(:socket) {mock TCPSocket}
      before(:each) do
        connection_throttle.max_connections = max_connections
      end

      context 'almost at maximum connections' do
        let(:connections) {max_connections - 1}
        specify {connection_throttle.allow?(socket).should be_true}
      end

      context 'at maximum connections' do
        let(:connections) {max_connections}
        specify {connection_throttle.allow?(socket).should be_false}
      end

      context 'above maximum connections' do
        let(:connections) {max_connections + 1}
        specify {connection_throttle.allow?(socket).should be_false}
      end

    end

    describe '#deny' do
      
      let(:socket) {StringIO.new}

      it 'should send a "too many connections" message' do
        connection_throttle.deny socket
        socket.string.should == "421 Too many connections\r\n"
      end

    end

  end

end
