module Ftpd

  class CmdType < CommandHandler

    def cmd_type(argument)
      ensure_logged_in
      syntax_error unless argument =~ /^(\S)(?: (\S+))?$/
      type_code = $1
      format_code = $2
      unless argument =~ /^([AEI]( [NTC])?|L .*)$/
        error '504 Invalid type code'
      end
      case argument
      when /^A( [NT])?$/
        self.data_type = 'A'
      when /^(I|L 8)$/
        self.data_type = 'I'
      else
        error '504 Type not implemented'
      end
      reply "200 Type set to #{data_type}"
    end

  end

end
