# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  # The Quit (QUIT) command

  class CmdQuit < CommandHandler

    def cmd_quit(argument)
      syntax_error if argument
      ensure_logged_in
      reply "221 Byebye"
      self.logged_in = false
    end

  end

end
