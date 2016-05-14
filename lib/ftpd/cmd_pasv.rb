# frozen_string_literal: true

require_relative 'command_handler'
require_relative 'data_server_factory'

module Ftpd

  class CmdPasv < CommandHandler

    def cmd_pasv(argument)
      ensure_logged_in
      ensure_not_epsv_all
      if data_server
        reply "200 Already in passive mode"
      else
        self.data_server = data_server_factory.make_tcp_server
        ip = config.nat_ip || data_server.addr[3]
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
