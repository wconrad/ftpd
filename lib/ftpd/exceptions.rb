module Ftpd

  class FtpServerError < StandardError ; end

  def self.ftp_server_error(class_name)
    const_set class_name, Class.new(FtpServerError)
  end

  ftp_server_error :CommandError
  ftp_server_error :DriverError
  ftp_server_error :FileSystemError
  ftp_server_error :MissingDriverError

end
