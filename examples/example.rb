#!/usr/bin/env ruby

unless $:.include?(File.dirname(__FILE__) + '/../lib')
   $:.unshift(File.dirname(__FILE__) + '/../lib')
end

require 'ftpd'

class Example

  def initialize
    @data_dir = Ftpd::TempDir.make
    create_files
    @server = Ftpd::FtpServer.new(@data_dir)
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
    create_file 'README',
    "Temporary directory created by ftpd sample program\n"
  end

  def create_file(path, contents)
    full_path = File.expand_path(path, @data_dir)
    FileUtils.mkdir_p File.dirname(full_path)
    File.open(full_path, 'w') do |file|
      file.write contents
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
    puts "Directory: #{@data_dir}"
    puts "URI: ftp://#{HOST}:#{@server.port}"
  end

  def create_connection_script
    command_path = '/tmp/connect-to-example-ftp-server.sh'
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
