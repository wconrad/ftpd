module Ftpd
  module Error

    def error(message)
      raise CommandError, message
    end

    def transient_error(message)
      error "450 #{message}"
    end

    def unrecognized_error(s)
      error "500 Syntax error, command unrecognized: #{s.chomp}"
    end

    def unimplemented_error
      error "502 Command not implemented"
    end

    def sequence_error
      error "503 Bad sequence of commands"
    end

    def permanent_error(message)
      error "550 #{message}"
    end

    def syntax_error
      error "501 Syntax error"
    end

  end
end
