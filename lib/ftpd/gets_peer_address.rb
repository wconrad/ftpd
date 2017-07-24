# frozen_string_literal: true

module Ftpd

  module GetsPeerAddress

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
    #
    # @return [String] IP address

    def peer_ip(socket)
      if socket.respond_to?(:getpeername)
        # Non SSL
        sockaddr = socket.getpeername
        _port, host = Socket.unpack_sockaddr_in(sockaddr)
        host
      else
        # SSL
        BasicSocket.do_not_reverse_lookup = true
        socket.peeraddr.last
      end
    end

  end

end
