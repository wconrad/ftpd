# frozen_string_literal: true

require_relative 'command_handler'
require_relative 'data_server_factory'

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
          self.data_server = data_server_factory.make_tcp_server
          port = data_server.addr[1]
          reply "229 Entering extended passive mode (|||#{port}|)"
        end
      end
    end

  end

end
