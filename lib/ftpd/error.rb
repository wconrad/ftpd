module Ftpd
  module Error

    def error(message)
      raise CommandError, message
    end

    def unimplemented_error
      error "502 Command not implemented"
    end

  end
end
