require 'fileutils'
require 'forwardable'
require File.expand_path('test_server_files',
                         File.dirname(__FILE__))

class TestServer
  class TestServerDriver

    def initialize(temp_dir)
      @temp_dir = temp_dir
    end

    USER = 'user'
    PASSWORD = 'password'

    def authenticate(user, password)
      user == USER && password == PASSWORD
    end

    def file_system(user)
      TestServerFileSystem.new(@temp_dir)
    end

  end
end

class TestServer
  class TestServerFileSystem < Ftpd::DiskFileSystem

    def accessible?(ftp_path)
      return false if force_access_denied?(ftp_path)
      return true if force_file_system_error?(ftp_path)
      super
    end

    def exists?(ftp_path)
      return true if force_file_system_error?(ftp_path)
      super
    end

    def directory?(ftp_path)
      return true if force_file_system_error?(ftp_path)
      super
    end

    def delete(ftp_path)
      force_file_system_error(ftp_path)
      super
    end

    def read(ftp_path)
      force_file_system_error(ftp_path)
      super
    end

    def write(ftp_path, contents)
      force_file_system_error(ftp_path)
      super
    end

    private

    def force_file_system_error(ftp_path)
      if force_file_system_error?(ftp_path)
        raise Ftpd::FileSystemError, 'Unable to do it'
      end
    end

    def force_access_denied?(ftp_path)
      ftp_path =~ /forbidden/
    end

    def force_file_system_error?(ftp_path)
      ftp_path =~ /unable/
    end

  end
end

class TestServer

  extend Forwardable
  include FileUtils
  include TestServerFiles
  include Ftpd::InsecureCertificate

  def initialize(opts = {})
    @temp_dir = Ftpd::TempDir.make
    certfile_path = if opts[:tls]
                      insecure_certfile_path
                    else
                      nil
                    end
    @server = Ftpd::FtpServer.new(:port => 0,
                                  :certfile_path => certfile_path)
    @templates = TestFileTemplates.new
    @server.driver = TestServerDriver.new(@temp_dir)
    @server.start 
  end

  def stop
    @server.stop
  end

  def host
    'localhost'
  end

  def user
    TestServerDriver::USER
  end

  def password
    TestServerDriver::PASSWORD
  end

  def_delegator :@server, :port

  private

  def temp_dir
    @temp_dir
  end

end
