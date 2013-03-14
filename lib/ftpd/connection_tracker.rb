module Ftpd

  # This class keeps track of connections

  class ConnectionTracker

    def initialize
      @mutex = Mutex.new
      @connections = {}
    end

    # Return the total number of connections

    def connections
      @mutex.synchronize do
        @connections.values.inject(0, &:+)
      end
    end

    # Return the number of connections for a socket

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

    # Return the number of known IPs.  This exists for the benefit of
    # the test, so that it can know the tracker has properly forgotten
    # about an IP with no connections.

    def known_ip_count
      @mutex.synchronize do
        @connections.size
      end
    end

    private

    # Start tracking a connection

    def start_track(socket)
      @mutex.synchronize do
        ip = peer_ip(socket)
        @connections[ip] ||= 0
        @connections[ip] += 1
      end
    end

    # Stop tracking a connection

    def stop_track(socket)
      @mutex.synchronize do
        ip = peer_ip(socket)
        if (@connections[ip] -= 1) == 0
          @connections.delete(ip)
        end
      end
    end

    # Obtain the IP that the client connected _from_.
    #
    # How this is done depends upon which type of socket (SSL or not)
    # and what version of Ruby.
    #
    # * SSL socket
    #   * #peeraddr.  Uses BasicSocket.do_not_reverse_lookup.
    # * Ruby 1.8.7
    #   * #peeraddr, which does not take the "reverse lookup"
    #     argument, relying instead using
    #     BasicSocket.do_not_reverse_lookup.
    #   * #getpeername, which does not do a reverse lookup.  It is a
    #     little uglier than #peeraddr.
    # * Ruby >=1.9.3
    #   * #peeraddr, which takes the "reverse lookup" argument.
    #   * #getpeername - same as 1.8.7

    # @return [String] IP address

    def peer_ip(socket)
      if socket.respond_to?(:getpeername)
        # Non SSL
        sockaddr = socket.getpeername
        port, host = Socket.unpack_sockaddr_in(sockaddr)
        host
      else
        # SSL
        BasicSocket.do_not_reverse_lookup = true
        socket.peeraddr.last
      end
     end

  end

end
