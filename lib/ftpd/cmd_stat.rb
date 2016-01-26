# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdStat < CommandHandler

    def cmd_stat(argument)
      ensure_logged_in
      syntax_error if argument
      reply "211 #{server_name_and_version}"
    end

  end

end
