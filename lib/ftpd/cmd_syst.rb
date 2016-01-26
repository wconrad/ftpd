# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  # The System (SYST) command.

  class CmdSyst < CommandHandler

    def cmd_syst(argument)
      syntax_error if argument
      reply "215 UNIX Type: L8"
    end

  end

end
