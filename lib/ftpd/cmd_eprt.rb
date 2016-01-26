# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdEprt < CommandHandler

    def cmd_eprt(argument)
      ensure_logged_in
      ensure_not_epsv_all
      delim = argument[0..0]
      parts = argument.split(delim)[1..-1]
      syntax_error unless parts.size == 3
      protocol_code, address, port = *parts
      protocol_code = protocol_code.to_i
      ensure_protocol_supported protocol_code
      port = port.to_i
      set_active_mode_address address, port
      reply "200 EPRT command successful"
    end

  end

end
