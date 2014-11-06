require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd

  describe Server do

    describe '#join' do
      it 'calls server_thread#join' do
        expect_any_instance_of(Thread).to receive(:join)
        server = Ftpd::Server.new
        server.start
        server.join
      end
      context 'when server is not started' do
        it 'raises an error' do
          server = Ftpd::FtpServer.new(nil)
          expect { server.join }.to raise_error('Server is not started!')
        end
      end
    end

    describe 'reuse explicit port (github #23)' do

      # The bug being tested involves a race condition.  Monkey patch
      # the server so that start does not return until "accept" has
      # been called on the server socket.  This causes the test to
      # reliably expose the bug.

      def monkey_patch_server(server)

        class << server

          def start
            @accepting = Queue.new
            super
            wait_for_accept
          end

          def accept
            @accepting.enq true
            super
          end

          private

          def wait_for_accept
            @accepting.deq
            # There's a potential race condition in _this_ code:
            # @accepting is triggered just before the accept is done
            # on the socket, but it's possible that the server thread
            # has been preempted and accept has not yet been called.
            # A little sleep gives the server thread another shot at
            # actually getting the accept done before we continue.
            sleep 0.01
          end

        end

      end

      it do
        port = find_open_port
        2.times do
          server = Server.new
          monkey_patch_server server
          server.port = port
          server.start
          server.stop
        end
      end

      def find_open_port
        socket = TCPServer.new('localhost', 0)
        socket.addr[1].tap {socket.close}
      end

    end

  end

end
