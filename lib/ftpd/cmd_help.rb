# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdHelp < CommandHandler

    def cmd_help(argument)
      if argument
        target_command = argument.upcase
        if supported_commands.include?(target_command)
          reply "214 Command #{target_command} is recognized"
        else
          reply "214 Command #{target_command} is not recognized"
        end
      else
        reply '214-The following commands are recognized:'
        supported_commands.sort.each_slice(8) do |commands|
          line = commands.map do |command|
            '   %-4s' % command
          end.join
          reply line
        end
        reply '214 Have a nice day.'
      end
    end

  end

end
