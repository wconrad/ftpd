# frozen_string_literal: true

require_relative 'data_server_factory/random_ephemeral_port'
require_relative 'data_server_factory/specific_port_range'

module Ftpd

  # Factories for creating TCPServer used for passive mode
  # connections.
  module DataServerFactory

    attr_reader :tcp_server

    # Create a factory.
    #
    # @param interface [String] The IP address of the interface to
    #   bind to (e.g. "127.0.0.1")
    # @param ports [nil, Range] The range of ports to bind to.  If nil,
    #   then binds to a random ephemeral port.
    def self.make(interface, ports)
      if ports
        SpecificPortRange.new(interface, ports)
      else
        RandomEphemeralPort.new(interface)
      end
    end

    # @param interface [String] The IP address of the interface to
    #   bind to (e.g. "127.0.0.1")
    # @param ports [nil, Range] The range of ports to bind to.  If nil,
    #   then binds to a random ephemeral port.
    def initialize(interface, ports)
      @interface = interface
      @ports = ports
    end

    # @return [TCPServer]
    def make_tcp_server
      TCPServer.new(@interface, 0)
    end

  end

end
