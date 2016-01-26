# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdCdup < CommandHandler

    def cmd_cdup(argument)
      syntax_error if argument
      ensure_logged_in
      execute_command 'cwd', '..'
    end
    alias cmd_xcup :cmd_cdup

  end

end
