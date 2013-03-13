module Ftpd

  # This class keeps track of connections

  class ConnectionTracker

    def initialize
      @mutex = Mutex.new
      @connections = 0
    end

    # Return the total number of connections

    def connections
      @mutex.synchronize do
        @connections
      end
    end

    # Track a connection.  Yields to a block; the connection is
    # tracked until the block returns.

    def track(socket)
      start_track socket
      begin
        yield
      ensure
        stop_track socket
      end
    end

    private

    # Start tracking a connection

    def start_track(socket)
      @mutex.synchronize do
        @connections += 1
      end
    end

    # Stop tracking a connection

    def stop_track(socket)
      @mutex.synchronize do
        @connections -= 1
      end
    end

  end

end
