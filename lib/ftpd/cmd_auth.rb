require_relative 'command_handler'

module Ftpd

  class CmdAuth < CommandHandler

    def cmd_auth(security_scheme)
      ensure_tls_supported
      if socket.encrypted?
        error "503 AUTH already done"
      end
      unless security_scheme =~ /^TLS(-C)?$/i
        error "504 Security scheme not implemented: #{security_scheme}"
      end
      reply "234 AUTH #{security_scheme} OK."
      socket.encrypt
    end

  end

end
