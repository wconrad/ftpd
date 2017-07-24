# frozen_string_literal: true

module Ftpd

  module DataConnectionHelper

    def transmit_file(io, data_type = session.data_type)
      open_data_connection do |data_socket|
        socket = Ftpd::Stream.new(data_socket, data_type)
        handle_data_disconnect do
          socket.write(io)
        end
        config.log.debug "Sent #{socket.byte_count} bytes"
        reply "226 Transfer complete"
      end
    end

    def receive_file(path_to_advertise = nil, &block)
      open_data_connection(path_to_advertise) do |data_socket|
        socket = Ftpd::Stream.new(data_socket, data_type)
        handle_data_disconnect do
          yield socket
        end
        config.log.debug "Received #{socket.byte_count} bytes"
      end
    end

    def open_data_connection(path_to_advertise = nil, &block)
      send_start_of_data_connection_reply(path_to_advertise)
      if data_server
        if encrypt_data?
          open_passive_tls_data_connection(&block)
        else
          open_passive_data_connection(&block)
        end
      else
        if encrypt_data?
          open_active_tls_data_connection(&block)
        else
          open_active_data_connection(&block)
        end
      end
    end

    def open_passive_tls_data_connection
      open_passive_data_connection do |socket|
        make_tls_connection(socket) do |ssl_socket|
          yield(ssl_socket)
        end
      end
    end

    def open_active_tls_data_connection
      open_active_data_connection do |socket|
        make_tls_connection(socket) do |ssl_socket|
          yield(ssl_socket)
        end
      end
    end

    def open_active_data_connection
      data_socket = TCPSocket.new(data_hostname, data_port)
      begin
        yield(data_socket)
      ensure
        data_socket.close
      end
    end

    def open_passive_data_connection
      data_socket = data_server.accept
      begin
        yield(data_socket)
      ensure
        data_socket.close
      end
    end

    def handle_data_disconnect
      return yield
    rescue Errno::ECONNRESET, Errno::EPIPE
      reply "426 Connection closed; transfer aborted."
    end

    def send_start_of_data_connection_reply(path)
      if path
        reply "150 FILE: #{path}"
      else
        reply "150 Opening #{data_connection_description}"
      end
    end

    def data_connection_description
      [
        Session::DATA_TYPES[data_type][0],
        "mode data connection",
        ("(TLS)" if encrypt_data?)
      ].compact.join(' ')
    end

    def make_tls_connection(data_socket)
      ssl_socket = OpenSSL::SSL::SSLSocket.new(data_socket, socket.ssl_context)
      ssl_socket.accept
      begin
        yield(ssl_socket)
      ensure
        ssl_socket.close
      end
    end

    def close_data_server_socket_when_done
      yield
    ensure
      close_data_server_socket
    end

    def encrypt_data?
      data_channel_protection_level != :clear
    end

  end

end
