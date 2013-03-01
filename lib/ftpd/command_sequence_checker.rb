# Some commands are supposed to occur in sequence.  For example, USER
# must be immediately followed by PASS.  This class keeps track of
# when a specific command is expected, and raises a "bad sequence"
# error when that command is not next.

module Ftpd
  class CommandSequenceChecker

    include Error

    # Set the next command.
    #
    # @param command [String] The command.  Must be lowercase.

    def expect(command)
      @expected_command = command
    end

    # Check a command.  If expecting a specific command and this command
    # isn't it, then raise an error that will cause a "503 Bad sequence"
    # error to be sent.  After checking, the expected command is cleared
    # and any command will be accepted, unless #expect is called again.
    #
    # @param command [String] The command.  Must be lowercase.
    # @raise [CommandError] A "503 Bad sequence" error

    def check(command)
      if @expected_command
        begin
          sequence_error unless command == @expected_command
        ensure
          @expected_command = nil
        end
      end
    end

  end
end
