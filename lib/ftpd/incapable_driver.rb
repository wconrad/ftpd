require 'ftpd/exceptions'

module Ftpd
  class IncapableDriver

    def method_missing(method, *args)
      raise MissingDriverError,
        "This server has no driver.  Please give it one."
    end

  end
end
