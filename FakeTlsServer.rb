require 'openssl'
require File.expand_path('FakeServer', File.dirname(__FILE__))
require File.expand_path('ObjectUtil', File.dirname(__FILE__))

class FakeTlsServer < FakeServer

  private

  def make_server_socket
    ssl_server_socket = OpenSSL::SSL::SSLServer.new(super, ssl_context);
    ssl_server_socket.start_immediately = false
    ssl_server_socket
  end

  def accept
    socket = @server_socket.accept
    add_tls_methods_to_socket(socket)
    socket
  end

  def ssl_context
    context = OpenSSL::SSL::SSLContext.new
    File.open(certfile_path) do |certfile|
      context.cert = OpenSSL::X509::Certificate.new(certfile)
      certfile.rewind
      context.key = OpenSSL::PKey::RSA.new(certfile)
    end
    context
  end
  once :ssl_context

  def certfile_path
    File.join(File.dirname(__FILE__), 'insecure-test-cert.pem')
  end

  def add_tls_methods_to_socket(socket)
    context = ssl_context
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
