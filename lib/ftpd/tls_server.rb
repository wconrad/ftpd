# frozen_string_literal: true

require_relative 'server'

module Ftpd
  class TlsServer < Server

    # Whether or not to do TLS, and which flavor.
    #
    # One of:
    # * :off
    # * :explicit
    # * :implicit
    #
    # Notes:
    # * Defaults to :off
    # * Set this before calling #start.
    # * If other than :off, then #certfile_path must be set.
    #
    # @return [Symbol]

    attr_accessor :tls

    # The path of the SSL certificate to use for TLS.  Defaults to nil
    # (no SSL certificate).
    #
    # Set this before calling #start.
    #
    # @return [String]

    attr_accessor :certfile_path

    # Create a new TLS server.

    def initialize
      super
      @tls = :off
    end

    private

    def make_server_socket
      socket = super
      if tls_enabled?
        socket = OpenSSL::SSL::SSLServer.new(socket, ssl_context)
        socket.start_immediately = false
      end
      socket
    end

    def accept
      socket = @server_socket.accept
      if tls_enabled?
        add_missing_methods_to_socket socket
        add_tls_methods_to_socket socket
      end
      socket
    end

    def ssl_context
      unless @certfile_path
        raise ArgumentError, ":certfile required if tls enabled"
      end
      context = OpenSSL::SSL::SSLContext.new
      File.open(@certfile_path) do |certfile|
        context.cert = OpenSSL::X509::Certificate.new(certfile)
        certfile.rewind
        context.key = OpenSSL::PKey::RSA.new(certfile)
      end
      context
    end
    memoize :ssl_context

    # Add to the TLS socket some methods that regular socket has, but TLS socket is missing

    def add_missing_methods_to_socket(socket)

      def socket.local_address
        @io.local_address
      end

    end

    # Add to the TLS sockets some methods of our own invention that
    # make life a little easier.

    def add_tls_methods_to_socket(socket)
      class << socket

        def ssl_context
          context
        end

        def encrypted?
          !!cipher
        end

        def encrypt
          accept
        end

      end
    end

    private

    def tls_enabled?
      @tls != :off
    end

  end
end
