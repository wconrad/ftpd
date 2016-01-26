# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdStru < CommandHandler

    def cmd_stru(argument)
      syntax_error unless argument
      ensure_logged_in
      name, implemented = FILE_STRUCTURES[argument]
      error "Invalid structure code", 504 unless name
      error "Structure not implemented", 504 unless implemented
      self.structure = argument
      reply "200 File structure set to #{name}"
    end

    private

    FILE_STRUCTURES = {
      'R'=>['Record', false],
      'F'=>['File', true],
      'P'=>['Page', false],
    }

  end

end
