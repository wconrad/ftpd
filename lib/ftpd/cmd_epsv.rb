require_relative 'command_handler'

module Ftpd

  class CmdEpsv < CommandHandler

    def cmd_epsv(argument)
      ensure_logged_in
      if data_server
        reply "200 Already in passive mode"
      else
        if argument == 'ALL'
          self.epsv_all = true
          reply "220 EPSV now required for port setup"
        else
          protocol_code = argument && argument.to_i
          if protocol_code
            ensure_protocol_supported protocol_code
          end
          interface = socket.addr[3]
          self.data_server = TCPServer.new(interface, 0)
          port = data_server.addr[1]
          reply "229 Entering extended passive mode (|||#{port}|)"
        end
      end
    end

  end

end
