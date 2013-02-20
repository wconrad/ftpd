module Ftpd
  class Server

    def initialize(opts = {})
      port = opts[:port] || 22
      interface = opts[:interface] || 'localhost'
      @server_socket = make_server_socket(interface, port)
    end

    def interface
      @server_socket.addr[2]
    end

    def port
      @server_socket.addr[1]
    end

    def start
      @server_thread = make_server_thread
    end

    def stop
      @server_socket.close
    end

    private

    def make_server_socket(interface, port)
      return TCPServer.new(interface, port)
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
