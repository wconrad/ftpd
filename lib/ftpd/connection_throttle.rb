# frozen_string_literal: true

module Ftpd

  # This class limits the number of connections

  class ConnectionThrottle

    DEFAULT_MAX_CONNECTIONS = nil
    DEFAULT_MAX_CONNECTIONS_PER_IP = nil

    # The maximum number of connections, or nil if there is no limit.
    # @return [Integer]

    attr_accessor :max_connections

    # The maximum number of connections for an IP, or nil if there is
    # no limit.
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
      allow_by_total_count &&
        allow_by_ip_count(socket)
    end

    # Reject a connection

    def deny(socket)
      socket.write "421 Too many connections\r\n"
    end

    private

    def allow_by_total_count
      return true unless @max_connections
      @connection_tracker.connections < @max_connections
    end

    def allow_by_ip_count(socket)
      return true unless @max_connections_per_ip
      @connection_tracker.connections_for(socket) < @max_connections_per_ip
    end

  end

end
