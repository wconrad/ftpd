module Ftpd
  class Server

    include Memoizer

    # The interface to bind to (e.g. "127.0.0.1", "0.0.0.0",
    # "10.0.0.12", "::1", "::", etc.).  Defaults to "127.0.0.1"
    #
    # Set this before calling #start.
    #
    # @return [String]

    attr_accessor :interface

    # The port to bind to.  Defaults to 0, which causes an ephemeral
    # port to be used.  When bound to an ephemeral port, use
    # #bound_port to find out which port was actually bound to.
    #
    # Set this before calling #start.
    #
    # @return [String]

    attr_accessor :port

    def initialize
      @interface = '127.0.0.1'
      @port = 0
      @stopping = false
    end

    # The port the server is bound to.  Must not be called until after
    # #start is called.
    #
    # @return [Integer]

    def bound_port
      @server_socket.addr[1]
    end

    # Start the server.  This creates the server socket, and the
    # thread to service it.

    def start
      @server_socket = make_server_socket
      @server_thread = make_server_thread
    end

    # Stop the server.  This closes the server socket, which in turn
    # stops the thread.

    def stop
      @stopping = true
      @server_socket.close
    end

    private

    def make_server_socket
      return TCPServer.new(@interface, @port)
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
            rescue Errno::EBADF
              raise unless @stopping
              @stopping = false
              break
            end
            start_session socket
          rescue IOError
            break
          end
        end
      end
    end

    def start_session(socket)
      if allow_session?(socket)
        start_session_thread socket
      else
        deny_session socket
        close_socket socket
      end
    end

    def allow_session?(socket)
      true
    end

    def deny_session socket
    end

    def start_session_thread(socket)
      Thread.new do
        begin
          session socket
        rescue OpenSSL::SSL::SSLError => e
        ensure
          close_socket socket
        end
      end
    end

    def accept
      @server_socket.accept
    end

    def close_socket(socket)
      if socket.respond_to?(:shutdown)
        socket.shutdown rescue nil
        socket.read rescue nil
      end
    ensure
      socket.close
    end

  end
end
