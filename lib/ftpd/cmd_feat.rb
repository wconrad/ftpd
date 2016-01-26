# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdFeat < CommandHandler

    def cmd_feat(argument)
      syntax_error if argument
      reply '211-Extensions supported:'
      extensions.each do |extension|
        reply " #{extension}"
      end
      reply '211 END'
    end

    private

    def extensions
      [
        (TLS_EXTENSIONS if tls_enabled?),
        IPV6_EXTENSIONS,
        RFC_3659_EXTENSIONS,
      ].flatten.compact
    end

    TLS_EXTENSIONS = [
      'AUTH TLS',
      'PBSZ',
      'PROT'
    ]

    IPV6_EXTENSIONS = [
      'EPRT',
      'EPSV',
    ]

    RFC_3659_EXTENSIONS = [
      'MDTM',
      'SIZE',
    ]

  end

end
