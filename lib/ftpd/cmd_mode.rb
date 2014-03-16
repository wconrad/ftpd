module Ftpd

  class CmdMode < CommandHandler

    def cmd_mode(argument)
      syntax_error unless argument
      ensure_logged_in
      name, implemented = TRANSMISSION_MODES[argument]
      error "504 Invalid mode code" unless name
      error "504 Mode not implemented" unless implemented
      self.mode = argument
      reply "200 Mode set to #{name}"
    end

    private

    TRANSMISSION_MODES = {
      'B'=>['Block', false],
      'C'=>['Compressed', false],
      'S'=>['Stream', true],
    }

  end

end
