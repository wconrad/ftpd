module Ftpd

  # This class limits the number of connections

  class ConnectionThrottle

    DEFAULT_MAX_CONNECTIONS = 100

    # The maximum number of connections.
    # @return [Integer]

    attr_accessor :max_connections

    # @param connection_tracker [ConnectionTracker]

    def initialize(connection_tracker)
      @max_connections = DEFAULT_MAX_CONNECTIONS
      @connection_tracker = connection_tracker
    end

    # @return [Boolean] true if the connection should be allowed

    def allow?(socket)
      @connection_tracker.connections < @max_connections
    end

    # Reject a connection

    def deny(socket)
      socket.write "421 Too many connections\r\n"
    end

  end

end
