# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdMkd < CommandHandler

    def cmd_mkd(argument)
      syntax_error unless argument
      ensure_logged_in
      ensure_file_system_supports :mkdir
      path = File.expand_path(argument, name_prefix)
      ensure_accessible path
      ensure_exists File.dirname(path)
      ensure_directory File.dirname(path)
      ensure_does_not_exist path
      file_system.mkdir path
      reply %Q'257 "#{path}" created'
    end
    alias cmd_xmkd :cmd_mkd

  end

end
