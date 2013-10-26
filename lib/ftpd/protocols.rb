module Ftpd

  # With the commands EPORT and EPSV, the client sends a protocol code
  # to indicate whether it wants an IPV4 or an IPV6 connection.  This
  # class contains functions related to that protocol code.

  class Protocols

    module Codes
      IPV4 = 1
      IPV6 = 2
    end
    include Codes

    # @param socket [TCPSocket, OpenSSL::SSL::SSLSocket] The socket.
    #   It doesn't matter whether it's the server socket (the one on
    #   which #accept is called), or the socket returned by #accept.

    def initialize(socket)
      @socket = socket
    end

    # Can the socket support a connection in the indicated protocol?
    #
    # @param protocol_code [Integer] protocol code

    def supports_protocol?(protocol_code)
      protocol_codes.include?(protocol_code)
    end

    # What protocol codes does the socket support?
    #
    # @return [Array<Integer>] List of protocol codes

    def protocol_codes
      [
        (IPV4 if supports_ipv4?),
        (IPV6 if supports_ipv6?),
      ].compact
    end

    private

    def supports_ipv4?
      @socket.local_address.ipv4? || ipv6_dual_stack?
    end

    def supports_ipv6?
      @socket.local_address.ipv6?
    end

    def ipv6_dual_stack?
      return false unless Socket.const_defined?(:IPV6_V6ONLY)
      v6only = @socket.getsockopt(Socket::IPPROTO_IPV6,
                                  Socket::IPV6_V6ONLY).unpack('i')
      v6only == [0]
    end

  end

end
