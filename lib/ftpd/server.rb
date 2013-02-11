require 'socket'

module Ftpd
  class Server

    def initialize
      @server_socket = make_server_socket
    end

    def port
      @server_socket.addr[1]
    end

    def start
      @server_thread = make_server_thread
    end

    def stop
      # An apparent race condition causes this to sometimes not stop the
      # thread.  When this happens, the thread remains blocked in the
      # accept method; I hypothesize that this happens whenever the
      # close happens first.  Once this bug is fixed, join on the
      # thread.
      @server_socket.close
    end

    private

    def make_server_socket
      return TCPServer.new('localhost', 0)
    end

    def make_server_thread
      Thread.new do
        Thread.abort_on_exception = true
        loop do
          begin
            begin
              socket = accept
            rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINVAL
              IO.select([@server_socket])
              sleep(0.2)
              retry
            end
            start_session_thread socket
          rescue IOError
            break
          end
        end
      end
    end

    def start_session_thread(socket)
      Thread.new do
        begin
          session(socket)
        ensure
          socket.close
        end
      end
    end

    def accept
      @server_socket.accept
    end

  end
end
