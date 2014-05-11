#!/usr/bin/env ruby

unless $:.include?(File.dirname(__FILE__) + '/../lib')
  $:.unshift(File.dirname(__FILE__) + '/../lib')
end

require 'socket'
require 'thread'
require 'tmpdir'

def show(s)
  return
  print s + "\n"
end

class Server

  attr_accessor :port

  def initialize
    @interface = '127.0.0.1'
    @port = 0
    @stopping = false
    @start_queue = Queue.new
    @stop_queue = Queue.new
  end

  def start
    show 's #start'
    @server_socket = make_server_socket
    @server_thread = make_server_thread
    show 's waiting for start'
    show "s #{@start_queue.deq}"
  end

  def stop
    show 's #stop'
    @stopping = true
    @server_socket.shutdown
#    @server_socket.close
    show 's joining on thread'
#    @thread.join
    # show 's waiting for stop'
    # show "s #{@stop_queue.deq}"
  end

  private

  def make_server_socket
    return TCPServer.new(@interface, @port)
  end

  def make_server_thread
    @thread = Thread.new do
      show 't started'
      Thread.abort_on_exception = false
      begin
        @start_queue.enq 'started'
        server_thread
      rescue Exception
        show 't exception'
        @stop_queue.enq 'stopping'
        raise
      else
        show 't no exception'
        @stop_queue.enq 'stopping'
      end
    end
  end

  def server_thread
    loop do
      begin
        begin
          show 't waiting for bind'
          @server_socket.accept
          show 't bound'
        rescue Errno::EBADF, Errno::EINVAL => e
          show "t #{e}"
          raise unless @stopping
          break
        end
      rescue IOError
        show 't IOError'
        break
      end
    end
    show 't done'
  end

  def accept
  end

end

Dir.mktmpdir do |temp_dir|
  i = 0
  loop do
    i += 1
    begin
      if i % 1000 == 0
        print '.'
        $stdout.flush
      end
      server = Server.new
      server.port = 10000
      server.start
      server.stop
    rescue Errno::EADDRINUSE
      puts i
      raise
    end
  end
end
