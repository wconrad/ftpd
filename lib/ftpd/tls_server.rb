module Ftpd
  class TlsServer < Server

    def initialize(opts = {})
      @certfile_path = opts[:certfile_path]
      if tls_enabled?
        @ssl_context = make_ssl_context
      end
      super
    end

    private

    def make_server_socket(port) 
      socket = super(port)
      if tls_enabled?
        socket = OpenSSL::SSL::SSLServer.new(socket, @ssl_context);
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

    def make_ssl_context
      context = OpenSSL::SSL::SSLContext.new
      File.open(@certfile_path) do |certfile|
        context.cert = OpenSSL::X509::Certificate.new(certfile)
        certfile.rewind
        context.key = OpenSSL::PKey::RSA.new(certfile)
      end
      context
    end

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
      @certfile_path
    end

  end
end
