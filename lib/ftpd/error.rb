module Ftpd
  module Error

    def error(message)
      raise CommandError, message
    end

    def transient_error(message)
      error "450 #{message}"
    end

    def unimplemented_error
      error "502 Command not implemented"
    end

    def permanent_error(message)
      error "550 #{message}"
    end

  end
end
