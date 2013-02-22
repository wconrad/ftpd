module Ftpd
  class TlsServer < Server

    attr_accessor :tls
    attr_accessor :certfile_path

    def initialize
      super
      @tls = :off
      if tls_enabled?
        unless @certfile_path
          raise ArgumentError, ":certfile required if tls enabled"
        end
      end
    end

    private

    def make_server_socket
      socket = super
      if tls_enabled?
        socket = OpenSSL::SSL::SSLServer.new(socket, ssl_context);
        socket.start_immediately = false
      end
      socket
    end

    def accept
      socket = @server_socket.accept
      if tls_enabled?
        add_tls_methods_to_socket(socket)
      end
      socket
    end

    def ssl_context
      context = OpenSSL::SSL::SSLContext.new
      File.open(@certfile_path) do |certfile|
        context.cert = OpenSSL::X509::Certificate.new(certfile)
        certfile.rewind
        context.key = OpenSSL::PKey::RSA.new(certfile)
      end
      context
    end
    memoize :ssl_context

    def add_tls_methods_to_socket(socket)
      context = @ssl_context
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
