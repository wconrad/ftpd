# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  # The Data Port (PORT) command.

  class CmdPort < CommandHandler

    def cmd_port(argument)
      ensure_logged_in
      ensure_not_epsv_all
      pieces = argument.split(/,/)
      syntax_error unless pieces.size == 6
      pieces.collect! do |s|
        syntax_error unless s =~ /^\d{1,3}$/
        i = s.to_i
        syntax_error unless (0..255) === i
        i
      end
      hostname = pieces[0..3].join('.')
      port = pieces[4] << 8 | pieces[5]
      set_active_mode_address hostname, port
      reply "200 PORT command successful"
    end

  end

end
