#!/usr/bin/env ruby

# This example shows how to create a "write-only" file system for FTPD.

unless $:.include?(File.dirname(__FILE__) + "/../lib")
  $:.unshift(File.dirname(__FILE__) + "/../lib")
end

require "ftpd"
require "tmpdir"

class FileSystem

  def initialize(user)
    @user = user
  end

  def accessible?(ftp_path)
    true
  end

  def exists?(ftp_path)
    true
  end

  def directory?(ftp_path)
    false
  end

  def write(ftp_path, stream)
    puts "Received upload"
    puts "User: #{@user}"
    puts "ftp_path: #{@ftp_path}"
    puts "byte count: #{stream.read.size}"
  end
  
end

class Driver

  def initialize(temp_dir)
    @temp_dir = temp_dir
  end

  def authenticate(user, password)
    true
  end

  def file_system(user)
    FileSystem.new(user)
  end

end

Dir.mktmpdir do |temp_dir|
  driver = Driver.new(temp_dir)
  server = Ftpd::FtpServer.new(driver)
  server.start
  puts "Server listening on port #{server.bound_port}"
  gets
end
