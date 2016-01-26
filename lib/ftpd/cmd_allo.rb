# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  # The Allocate (ALLO) command.
  #
  # This server does not need the ALLO command, so treats it as a
  # NOOP.

  class CmdAllo < CommandHandler

    def cmd_allo(argument)
      ensure_logged_in
      syntax_error unless argument =~ /^\d+( R \d+)?$/
      command_not_needed
    end

  end

end
