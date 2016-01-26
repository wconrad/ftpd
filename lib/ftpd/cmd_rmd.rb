# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdRmd < CommandHandler

    def cmd_rmd(argument)
      syntax_error unless argument
      ensure_logged_in
      ensure_file_system_supports :rmdir
      path = File.expand_path(argument, name_prefix)
      ensure_accessible path
      ensure_exists path
      ensure_directory path
      file_system.rmdir path
      reply '250 RMD command successful'
    end
    alias cmd_xrmd :cmd_rmd

  end

end
