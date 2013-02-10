require 'openssl'
require File.expand_path('server', File.dirname(__FILE__))

module Ftpd
  class TlsServer < Server

    def initialize
      @ssl_context = make_ssl_context
      super
    end

    private

    def make_server_socket
      ssl_server_socket = OpenSSL::SSL::SSLServer.new(super, @ssl_context);
      ssl_server_socket.start_immediately = false
      ssl_server_socket
    end

    def accept
      socket = @server_socket.accept
      add_tls_methods_to_socket(socket)
      socket
    end

    def make_ssl_context
      context = OpenSSL::SSL::SSLContext.new
      File.open(certfile_path) do |certfile|
        context.cert = OpenSSL::X509::Certificate.new(certfile)
        certfile.rewind
        context.key = OpenSSL::PKey::RSA.new(certfile)
      end
      context
    end

    def certfile_path
      File.expand_path('../../insecure-test-cert.pem',
                       File.dirname(__FILE__))
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

  end
end
