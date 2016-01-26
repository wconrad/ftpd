# frozen_string_literal: true

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

    subject(:connection_tracker) {ConnectionTracker.new}

    describe '#connections' do

      let(:socket) {socket_bound_to('127.0.0.1')}

      context '(session ends normally)' do

        it 'should track the total number of connection' do
          expect(connection_tracker.connections).to eq 0
          connection_tracker.start_track socket
          expect(connection_tracker.connections).to eq 1
          connection_tracker.stop_track socket
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
        connection_tracker.start_track socket1
        expect(connection_tracker.connections_for(socket1)).to eq 1
        expect(connection_tracker.connections_for(socket2)).to eq 0
        connection_tracker.stop_track socket1
        expect(connection_tracker.connections_for(socket1)).to eq 0
        expect(connection_tracker.connections_for(socket2)).to eq 0
      end

    end

    describe '#known_ip_count' do

      let(:socket) {socket_bound_to('127.0.0.1')}

      it 'should forget about an IP that has no connection' do
        expect(connection_tracker.known_ip_count).to eq 0
        connection_tracker.start_track socket
        expect(connection_tracker.known_ip_count).to eq 1
        connection_tracker.stop_track socket
        expect(connection_tracker.known_ip_count).to eq 0
      end

    end

    describe '#track' do

      let(:socket) {socket_bound_to('127.0.0.1')}

      context '(session ends normally)' do
        specify do
          expect(connection_tracker.connections_for(socket)).to eq 0
          connection_tracker.track(socket) do
            expect(connection_tracker.connections_for(socket)).to eq 1
          end
          expect(connection_tracker.connections_for(socket)).to eq 0
        end
      end

      context '(session ends with exception)' do
        specify do
          expect(connection_tracker.connections_for(socket)).to eq 0
          connection_tracker.track(socket) { raise } rescue
          expect(connection_tracker.connections_for(socket)).to eq 0
        end
      end

    end

  end

end
