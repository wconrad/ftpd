# frozen_string_literal: true

module Ftpd

  module DataServerFactory

    # Factory for creating TCPServer used for passive mode
    # connections.  This factory binds to a random port within a
    # specific range of ports.
    class SpecificPortRange

      # @param interface [String] The IP address of the interface to
      #   bind to (e.g. "127.0.0.1")
      # @param ports [nil, Range] The range of ports to bind to.
      def initialize(interface, ports)
        @interface = interface
        @ports = ports
      end

      # @return [TCPServer]
      def make_tcp_server
        ports_to_try = @ports.to_a.shuffle
        until ports_to_try.empty?
          port = ports_to_try.shift
          begin
            return TCPServer.new(@interface, port)
          rescue Errno::EADDRINUSE
          end
        end
        TCPServer.new(@interface, 0)
      end

    end

  end

end
