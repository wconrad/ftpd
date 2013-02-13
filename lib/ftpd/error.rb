module Ftpd
  module Error

    def error(message)
      raise CommandError, message
    end

    def access_denied_error
      error '550 Access denied'
    end

  end
end
