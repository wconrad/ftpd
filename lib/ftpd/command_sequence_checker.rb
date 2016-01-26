# frozen_string_literal: true

# Some commands are supposed to occur in sequence.  For example, USER
# must be immediately followed by PASS.  This class keeps track of
# when a specific command either must arrive or must not arrive, and
# raises a "bad sequence" error when commands arrive in the wrong
# sequence.

module Ftpd
  class CommandSequenceChecker

    include Error

    def initialize
      @must_expect = []
      @expected_command = nil
    end

    # Set the command to expect next.  If not set, then any command
    # will be accepted, so long as it hasn't been registered using
    # {#must_expect}.  Otherwise, the set command must be next or a
    # sequence error will result.
    #
    # @param command [String] The command.  Must be lowercase.

    def expect(command)
      @expected_command = command
    end

    # Register a command that must be expected.  When that command is
    # received without {#expect} having been called for it, a sequence
    # error will result.

    def must_expect(command)
      @must_expect << command
    end

    # Check a command.  If expecting a specific command and this
    # command isn't it, then raise an error that will cause a "503 Bad
    # sequence" error to be sent.  After checking, the expected
    # command is cleared and any command will be accepted until
    # {#expect} is called again.
    #
    # @param command [String] The command.  Must be lowercase.
    # @raise [FtpServerError] A "503 Bad sequence" error

    def check(command)
      if @expected_command
        begin
          sequence_error unless command == @expected_command
        ensure
          @expected_command = nil
        end
      else
        sequence_error if @must_expect.include?(command)
      end
    end

  end
end
