# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdOpts < CommandHandler

    def cmd_opts(argument)
      syntax_error unless argument
      error 'Unsupported option', 501
    end

  end

end
