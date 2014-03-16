module Ftpd

  class CmdOpts < CommandHandler

    def cmd_opts(argument)
      syntax_error unless argument
      error '501 Unsupported option'
    end

  end

end
