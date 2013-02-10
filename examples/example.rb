#!/usr/bin/env ruby

unless $:.include?(File.dirname(__FILE__) + '/../lib')
   $:.unshift(File.dirname(__FILE__) + '/../lib')
end

require 'ftpd'

class Example

  def initialize
    @data_dir = Ftpd::TempDir.new
    create_files
    @server = Ftpd::FtpServer.new(@data_dir.path)
    set_credentials
    display_connection_info
    create_connection_script
  end

  def run
    wait_until_stopped
  end

  private
  
  HOST = 'localhost'

  def create_files
    [
      'README',
      'outgoing/getme',
    ].each do |path|
      base_name = File.basename(path)
      dir_name = File.dirname(path)
      dir_path = File.join(@data_dir.path, dir_name)
      file_path = File.join(dir_path, base_name)
      FileUtils.mkdir_p(dir_path)
      File.open(file_path, 'w') do |file|
        file.puts "Contents of #{path}"
      end
    end
  end

  def set_credentials
    @server.user = ENV['LOGNAME']
    @server.password = ''
  end

  def display_connection_info
    puts "Host: #{HOST}"
    puts "Port: #{@server.port}"
    puts "User: #{@server.user}"
    puts "Pass: #{@server.password}"
    puts "Directory: #{@data_dir.path}"
  end

  def create_connection_script
    command_path = '/tmp/connect_to_fake_ftp_server.sh'
    File.open(command_path, 'w') do |file|
      file.puts "#!/bin/bash"
      file.puts "ftp $FTP_ARGS #{HOST} #{@server.port}"
    end
    system("chmod +x #{command_path}")
    puts "Connection script written to #{command_path}"
  end

  def wait_until_stopped
    puts "FTP server started.  Press ENTER or c-C to stop it"
    $stdout.flush
    begin
      gets
    rescue Interrupt
      puts "Interrupt"
    end
  end

end

Example.new.run if $0 == __FILE__
