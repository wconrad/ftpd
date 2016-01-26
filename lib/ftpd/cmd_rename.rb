# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdRename < CommandHandler

    def cmd_rnfr(argument)
      ensure_logged_in
      ensure_file_system_supports :rename
      syntax_error unless argument
      from_path = File.expand_path(argument, name_prefix)
      ensure_accessible from_path
      ensure_exists from_path
      @rename_from_path = from_path
      reply '350 RNFR accepted; ready for destination'
      expect 'rnto'
    end

    def cmd_rnto(argument)
      ensure_logged_in
      ensure_file_system_supports :rename
      syntax_error unless argument
      to_path = File.expand_path(argument, name_prefix)
      ensure_accessible to_path
      ensure_does_not_exist to_path
      file_system.rename(@rename_from_path, to_path)
      reply '250 Rename successful'
    end

  end

end
