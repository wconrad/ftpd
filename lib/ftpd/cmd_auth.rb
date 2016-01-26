# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdAuth < CommandHandler

    def cmd_auth(security_scheme)
      ensure_tls_supported
      if socket.encrypted?
        error "AUTH already done", 503
      end
      unless security_scheme =~ /^TLS(-C)?$/i
        error "Security scheme not implemented: #{security_scheme}", 504
      end
      reply "234 AUTH #{security_scheme} OK."
      socket.encrypt
    end

  end

end
