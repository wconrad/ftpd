#!/usr/bin/env ruby

unless $:.include?(File.dirname(__FILE__) + '/../lib')
  $:.unshift(File.dirname(__FILE__) + '/../lib')
end

require 'ftpd'

FTP_DIR = '/tmp/ftp'

class Driver

  def authenticate(user, password)
    true
  end

  def file_system(user)
    Ftpd::DiskFileSystem.new(FTP_DIR)
  end

end

Dir.mkdir FTP_DIR
server = 
  Ftpd::FtpServer.new(:driver => Driver.new)
puts "Server listening on port #{server.port}"
server.start
gets
