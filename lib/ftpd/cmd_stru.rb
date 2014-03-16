module Ftpd

  class CmdStru < CommandHandler

    def cmd_stru(argument)
      syntax_error unless argument
      ensure_logged_in
      name, implemented = FILE_STRUCTURES[argument]
      error "504 Invalid structure code" unless name
      error "504 Structure not implemented" unless implemented
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
