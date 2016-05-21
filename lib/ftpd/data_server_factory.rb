# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  # Factory for creating TCPServer used for passive mode connections.
  class DataServerFactory

    attr_reader :tcp_server

    # @param interface [String] The IP address of the interface to
    # bind to (e.g. "127.0.0.1")
    def initialize(interface)
      @interface = interface
    end

    # @return [TCPServer]
    def make_tcp_server
      TCPServer.new(@interface, 0)
    end

  end

end
