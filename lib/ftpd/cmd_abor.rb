# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdAbor < CommandHandler

    def cmd_abor(argument)
      unimplemented_error
    end

  end

end
