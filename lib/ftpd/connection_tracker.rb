module Ftpd

  # This class rejects new connections when there are too many.

  class ConnectionTracker

    # @param max_connections [Integer] The maximum number of
    #   connections to accept

    def initialize(max_connections)
      @max_connections = max_connections
      @mutex = Mutex.new
      @connections = 0
    end

    # Accept or reject a connection.
    # * If the connection is accepted, yield.
    # * If the connection is not accepted, write a 421 response and do
    #   not yield.

    def track(socket)
      @mutex.lock
      if @max_connections && @connections >= @max_connections
        @mutex.unlock
        socket.write "421 Too many connections\n\r"
      else
        begin
          @connections += 1
          @mutex.unlock
          yield
        ensure
          @mutex.synchronize do
            @connections -= 1
          end
        end
      end
    end

  end

end
