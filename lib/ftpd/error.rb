module Ftpd
  module Error

    def error(message)
      raise CommandError, message
    end

  end
end
