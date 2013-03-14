module Ftpd

  # This class limits the number of connections

  class ConnectionThrottle

    DEFAULT_MAX_CONNECTIONS = 200
    DEFAULT_MAX_CONNECTIONS_PER_IP = 5

    # The maximum number of connections.
    # @return [Integer]

    attr_accessor :max_connections

    # The maximum number of connections for an IP.
    # @return [Integer]

    attr_accessor :max_connections_per_ip

    # @param connection_tracker [ConnectionTracker]

    def initialize(connection_tracker)
      @max_connections = DEFAULT_MAX_CONNECTIONS
      @max_connections_per_ip = DEFAULT_MAX_CONNECTIONS_PER_IP
      @connection_tracker = connection_tracker
    end

    # @return [Boolean] true if the connection should be allowed

    def allow?(socket)
      @connection_tracker.connections < @max_connections &&
        @connection_tracker.connections_for(socket) < @max_connections_per_ip
    end

    # Reject a connection

    def deny(socket)
      socket.write "421 Too many connections\r\n"
    end

  end

end
