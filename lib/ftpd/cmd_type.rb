# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdType < CommandHandler

    def cmd_type(argument)
      ensure_logged_in
      syntax_error unless argument =~ /^\S(?: \S+)?$/
      unless argument =~ /^([AEI]( [NTC])?|L .*)$/
        error 'Invalid type code', 504
      end
      case argument
      when /^A( [NT])?$/
        self.data_type = 'A'
      when /^(I|L 8)$/
        self.data_type = 'I'
      else
        error 'Type not implemented', 504
      end
      reply "200 Type set to #{data_type}"
    end

  end

end
