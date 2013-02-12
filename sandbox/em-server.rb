#!/usr/bin/env ruby

require 'eventmachine'

 module EchoServer

   def post_init
     p 'post_init'
   end

   def connection_completed
     p 'connection_completed'
   end

   def receive_data data
     send_data ">>>you sent: #{data}"
     close_connection if data =~ /quit/i
   end

   def unbind
     p 'unbind'
  end
end

def get_port_for_fd(fd)
  sockname = EM.get_sockname(fd)
  port, host = Socket.unpack_sockaddr_in(sockname)
  port
end

# Note that this will block current thread.
 EventMachine.run {
   fd = EventMachine.start_server "127.0.0.1", 0, EchoServer do |e|
     p e
   end
  p get_port_for_fd(fd)
 }
