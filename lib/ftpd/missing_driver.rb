module Ftpd
  class MissingDriver

    def method_missing(method, *args)
      raise MissingDriverError,
        "This server has no driver.  Please give it one."
    end

  end
end
