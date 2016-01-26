# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdDele < CommandHandler

    def cmd_dele(argument)
      ensure_logged_in
      ensure_file_system_supports :delete
      path = argument
      error "Path required", 501 unless path
      path = File.expand_path(path, name_prefix)
      ensure_accessible path
      ensure_exists path
      file_system.delete path
      reply "250 DELE command successful"
    end

  end

end
