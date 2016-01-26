# frozen_string_literal: true

module Ftpd

  # All FTP commands which the server supports are dispatched by this
  # class.

  class CommandHandlers

    def initialize
      @commands = {}
    end

    # Add a command handler
    #
    # @param command_handler [Command]

    def <<(command_handler)
      command_handler.commands.each do |command|
        @commands[command] = command_handler
      end
    end

    # @param command [String] the command (e.g. "STOR").  Case
    #   insensitive.
    # @return truthy if the server supports the command.

    def has?(command)
      command = canonical_command(command)
      @commands.has_key?(command)
    end

    # Dispatch a command to the appropriate command handler.
    #
    # @param command [String] the command (e.g. "STOR").  Case
    #   insensitive.
    # @param argument [String] The argument, or nil if there isn't
    #   one.

    def execute(command, argument)
      command = canonical_command(command)
      method = "cmd_#{command}"
      @commands[command.downcase].send(method, argument)
    end

    # Return the sorted list of commands supported by this handler
    #
    # @return [Array<String>] Lowercase command

    def commands
      @commands.keys.sort
    end

    private

    def canonical_command(command)
      command.downcase
    end

  end

end
