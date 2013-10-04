# -*- ruby encoding: us-ascii -*-

module Ftpd

  # Handle the limited processing of Telnet sequences required by the
  # FTP RFCs.
  #
  # Telnet option processing is quite complex, but we need do only a
  # simple subset of it, since we can disagree with any request by the
  # client to turn on an option (RFC-1123 4.1.2.12).  Adhering to
  # RFC-1143 ("The Q Method of Implementing TELNET Option Negiation"),
  # and supporting only what's needed to keep all options turned off:
  #
  # * Reply to WILL sequence with DONT sequence
  # * Reply to DO sequence with WONT sequence
  # * Ignore WONT sequence
  # * Ignore DONT sequence
  #
  # We also handle the "interrupt process" and "data mark" sequences,
  # which the client sends before the ABORT command, by ignoring them.
  #
  # All Telnet sequence start with an IAC, followed by at least one
  # character.  Here are the sequences we care about:
  #
  #     SEQUENCE             CODES
  #     -----------------    --------------------
  #     WILL                 IAC WILL option-code
  #     WONT                 IAC WONT option-code
  #     DO                   IAC DO option-code
  #     DONT                 IAC DONT option-code
  #     escaped 255          IAC IAC
  #     interrupt process    IAC IP
  #     data mark            IAC DM
  #
  # Any pathalogical sequence (e.g. IAC + \x01), or any sequence we
  # don't recognize, we pass through.

  class Telnet

    # The command with recognized Telnet sequences removed

    attr_reader :plain

    # Any Telnet sequences to send

    attr_reader :reply

    # Create a new instance with a command that may contain Telnet
    # sequences.
    # @param command [String]

    def initialize(command)
      parse_command command
    end

    private

    module Codes
      IAC  = 255.chr    # 0xff
      DONT = 254.chr    # 0xfe
      DO   = 253.chr    # 0xfd
      WONT = 252.chr    # 0xfc
      WILL = 251.chr    # 0xfb
      IP   = 244.chr    # 0xf4
      DM   = 242.chr    # 0xf2
    end
    include Codes

    # Parse the the command.  Sets @plain and @reply

    def parse_command(command)
      @plain = ''
      @reply = ''
      state = :idle
      command.each_char do |c|
        case state
        when :idle
          if c == IAC
            state = :iac
          else
            @plain << c
          end
        when :iac
          case c
          when IAC
            @plain << c
            state = :idle
          when WILL
            state = :will
          when WONT
            state = :wont
          when DO
            state = :do
          when DONT
            state = :dont
          when IP
            state = :idle
          when DM
            state = :idle
          else
            @plain << IAC + c
            state = :idle
          end
        when :will
          @reply << IAC + DONT + c
          state = :idle
        when :wont
          state = :idle
        when :do
          @reply << IAC + WONT + c
          state = :idle
        when :dont
          state = :idle
        else
          raise "Unknown state #{state.inspect}"
        end
      end
    end

  end
end
