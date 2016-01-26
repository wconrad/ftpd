# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdPwd < CommandHandler

    def cmd_pwd(argument)
      ensure_logged_in
      pwd 257
    end
    alias cmd_xpwd :cmd_pwd

  end

end
