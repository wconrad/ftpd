# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdPbsz < CommandHandler

    def cmd_pbsz(buffer_size)
      ensure_tls_supported
      syntax_error unless buffer_size =~ /^\d+$/
      buffer_size = buffer_size.to_i
      unless socket.encrypted?
        error "PBSZ must be preceded by AUTH", 503
      end
      unless buffer_size == 0
        error "PBSZ=0", 501
      end
      reply "200 PBSZ=0"
      self.protection_buffer_size_set = true
    end

  end

end
