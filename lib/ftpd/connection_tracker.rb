# frozen_string_literal: true

require_relative "gets_peer_address"

module Ftpd

  # This class keeps track of connections

  class ConnectionTracker

    include GetsPeerAddress

    def initialize
      @mutex = Mutex.new
      @connections = {}
      @socket_ips ={}
    end

    # Return the total number of connections

    def connections
      @mutex.synchronize do
        @connections.values.inject(0, &:+)
      end
    end

    # Return the number of connections for a socket's peer IP

    def connections_for(socket)
      @mutex.synchronize do
        ip = peer_ip(socket)
        @connections[ip] || 0
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

    # Start tracking a connection

    def start_track(socket)
      @mutex.synchronize do
        ip = peer_ip(socket)
        @connections[ip] ||= 0
        @connections[ip] += 1
        @socket_ips[socket.object_id] = ip
      end
    rescue Errno::ENOTCONN
    end

    # Stop tracking a connection

    def stop_track(socket)
      @mutex.synchronize do
        ip = @socket_ips.delete(socket.object_id)
        break unless ip
        if (@connections[ip] -= 1) == 0
          @connections.delete(ip)
        end
      end
    end

    # Return the number of known IPs.  This exists for the benefit of
    # the test, so that it can know the tracker has properly forgotten
    # about an IP with no connections.

    def known_ip_count
      @mutex.synchronize do
        @connections.size
      end
    end

    private

  end

end
