# -*- ruby encoding: us-ascii -*-
# frozen_string_literal: true

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

    def accept(scanner)
      @plain << scanner[1]
    end

    def reply_dont(scanner)
      @reply << IAC + DONT + scanner[1]
    end

    def reply_wont(scanner)
      @reply << IAC + WONT + scanner[1]
    end

    def ignore(scanner)
    end

    # Telnet sequences to handle, and how to handle them

    SEQUENCES = [
      [/#{IAC}(#{IAC})/, :accept],
      [/#{IAC}#{WILL}(.)/m, :reply_dont],
      [/#{IAC}#{WONT}(.)/m, :ignore],
      [/#{IAC}#{DO}(.)/m, :reply_wont],
      [/#{IAC}#{DONT}(.)/m, :ignore],
      [/#{IAC}#{IP}/, :ignore],
      [/#{IAC}#{DM}/, :ignore],
      [/(.)/m, :accept],
    ]

    # Parse the the command.  Sets @plain and @reply

    def parse_command(command)
      @plain = ''.dup
      @reply = ''.dup
      scanner = StringScanner.new(command)
      while !scanner.eos?
        SEQUENCES.each do |regexp, method|
          if scanner.scan(regexp)
            send method, scanner
            break
          end
        end
      end
    end

  end
end
