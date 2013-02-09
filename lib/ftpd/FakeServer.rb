require 'socket'

class FakeServer

  def initialize
    @server_socket = make_server_socket
    @server_thread = make_server_thread
  end

  def port
    @server_socket.addr[1]
  end

  def close
    # An apparent race condition causes this to sometimes not stop the
    # thread.  When this happens, the thread remains blocked in the
    # accept method; I hypothesize that this happens whenever the
    # close happens first.  Once this bug is fixed, join on the
    # thread.
    @server_socket.close
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
