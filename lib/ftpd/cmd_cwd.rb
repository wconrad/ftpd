# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdCwd < CommandHandler

    def cmd_cwd(argument)
      ensure_logged_in
      path = File.expand_path(argument, name_prefix)
      ensure_accessible path
      ensure_exists path
      ensure_directory path
      self.name_prefix = path
      pwd 250
    end
    alias cmd_xcwd :cmd_cwd

  end

end
