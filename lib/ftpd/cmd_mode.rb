# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdMode < CommandHandler

    def cmd_mode(argument)
      syntax_error unless argument
      ensure_logged_in
      name, implemented = TRANSMISSION_MODES[argument]
      error "Invalid mode code", 504 unless name
      error "Mode not implemented", 504 unless implemented
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
