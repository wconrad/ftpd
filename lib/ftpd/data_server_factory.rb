# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  # Factory for creating TCPServer used for passive mode connections.
  class DataServerFactory

    attr_reader :tcp_server

    def initialize(socket)
      @socket = socket
    end

    def make_tcp_server
      interface = @socket.addr[3]
      TCPServer.new(interface, 0)
    end

  end

end
