module Ftpd

  class CmdNoop < CommandHandler

    def cmd_noop(argument)
      syntax_error if argument
      reply "200 Nothing done"
    end

  end

end
