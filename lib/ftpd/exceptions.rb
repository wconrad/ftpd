module Ftpd

  class FtpServerError < StandardError ; end

  class MissingDriverError < FtpServerError ; end

end
