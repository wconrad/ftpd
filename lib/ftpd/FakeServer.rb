require 'socket'

class FakeServer

  def initialize
    @server_socket = make_server_socket
    make_server_thread
  end

  def port
    @server_socket.addr[1]
  end

  private

  def make_server_socket
    return TCPServer.new('localhost', 0)
  end

  def make_server_thread
    Thread.new do
      Thread.abort_on_exception = true
      loop do
        begin
          begin
            socket = accept
          rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINVAL
            IO.select([@server_socket])
            sleep(0.2)
            retry
          end
          begin
            session(socket)
          ensure
            socket.close
          end
        rescue IOError
          break
        end
      end
    end
  end

  def accept
    @server_socket.accept
  end

end
