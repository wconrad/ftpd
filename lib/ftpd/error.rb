# frozen_string_literal: true

module Ftpd
  module Error

    def error(message, code)
      raise FtpServerError.new(message, code)
    end

    def unimplemented_error
      error "Command not implemented", 502
    end

    def sequence_error
      error "Bad sequence of commands", 503
    end

    def syntax_error
      error "Syntax error", 501
    end

  end
end
