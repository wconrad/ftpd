require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd

  describe ConnectionThrottle do

    let(:socket) {double TCPSocket}
    let(:connections) {0}
    let(:connections_for_socket) {0}
    let(:connection_tracker) do
      double ConnectionTracker, :connections => connections
    end
    subject(:connection_throttle) do
      ConnectionThrottle.new(connection_tracker)
    end

    before(:each) do
      allow(connection_tracker).to receive(:connections)
      .and_return(connections)
      allow(connection_tracker).to receive(:connections_for)
      .with(socket)
      .and_return(connections_for_socket)
    end

    it 'should have defaults' do
      expect(connection_throttle.max_connections).to be_nil
      expect(connection_throttle.max_connections_per_ip).to be_nil
    end

    describe '#allow?' do

      context '(total connections)' do
        
        let(:max_connections) {50}

        before(:each) do
          connection_throttle.max_connections = max_connections
          connection_throttle.max_connections_per_ip = 2 * max_connections
        end

        context 'almost at maximum connections' do
          let(:connections) {max_connections - 1}
          specify {expect(connection_throttle.allow?(socket)).to be_truthy}
        end

        context 'at maximum connections' do
          let(:connections) {max_connections}
          specify {expect(connection_throttle.allow?(socket)).to be_falsey}
        end

        context 'above maximum connections' do
          let(:connections) {max_connections + 1}
          specify {expect(connection_throttle.allow?(socket)).to be_falsey}
        end

      end

      context '(per ip)' do
        
        let(:max_connections_per_ip) {5}

        before(:each) do
          connection_throttle.max_connections = 2 * max_connections_per_ip
          connection_throttle.max_connections_per_ip = max_connections_per_ip
        end

        context 'almost at maximum connections for ip' do
          let(:connections_for_socket) {max_connections_per_ip - 1}
          specify {expect(connection_throttle.allow?(socket)).to be_truthy}
        end

        context 'at maximum connections for ip' do
          let(:connections_for_socket) {max_connections_per_ip}
          specify {expect(connection_throttle.allow?(socket)).to be_falsey}
        end

        context 'above maximum connections for ip' do
          let(:connections_for_socket) {max_connections_per_ip + 1}
          specify {expect(connection_throttle.allow?(socket)).to be_falsey}
        end

      end

    end

    describe '#deny' do
      
      let(:socket) {StringIO.new}

      it 'should send a "too many connections" message' do
        connection_throttle.deny socket
        expect(socket.string).to eq "421 Too many connections\r\n"
      end

    end

  end

end
