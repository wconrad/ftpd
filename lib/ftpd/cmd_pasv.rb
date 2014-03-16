module Ftpd

  class CmdPasv < CommandHandler

    def cmd_pasv(argument)
      ensure_logged_in
      ensure_not_epsv_all
      if data_server
        reply "200 Already in passive mode"
      else
        interface = socket.addr[3]
        self.data_server = TCPServer.new(interface, 0)
        ip = data_server.addr[3]
        port = data_server.addr[1]
        quads = [
          ip.scan(/\d+/),
          port >> 8,
          port & 0xff,
        ].flatten.join(',')
        reply "227 Entering passive mode (#{quads})"
      end
    end

  end

end
