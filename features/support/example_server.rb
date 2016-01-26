# frozen_string_literal: true

require 'fileutils'
require 'forwardable'
require File.expand_path('test_server_files',
                         File.dirname(__FILE__))

class ExampleServer

  extend Forwardable
  include FileUtils
  include TestServerFiles

  def initialize(args = nil)
    command = [
      File.expand_path('../../examples/example.rb',
                       File.dirname(__FILE__)),
      args,
    ].join(' ')
    @io = IO.popen(command, 'r+')
    @output = read_output
  end

  def stop 
    @io.close
  end

  def host
    @output[/Host: (.*)$/, 1]
  end

  def port
    @output[/Port: (.*)$/, 1].to_i
  end

  def user
    @output[/User: "(.*)"$/, 1]
  end

  def password
    @output[/Pass: "(.*)"$/, 1]
  end

  def account
    @output[/Account: "(.*)"$/, 1]
  end

  def auth_level
    Ftpd::AUTH_PASSWORD
  end

  private

  def read_output
    output = ''.dup
    loop do
      line = @io.gets
      break if line.nil?
      output << line
      break if line =~ /FTP server started/
    end
    output
  end

  def temp_dir
    @output[/Directory: (.*)$/, 1]
  end

end
