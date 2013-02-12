module Ftpd

  class FtpServerError < StandardError ; end

  class MissingDriverError < FtpServerError ; end

  class CommandError < FtpServerError ; end

end
