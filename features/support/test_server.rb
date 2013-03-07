require 'fileutils'
require 'forwardable'
require 'tempfile'

require File.expand_path('test_server_files',
                         File.dirname(__FILE__))

class TestServer
  class TestServerDriver

    extend Forwardable

    USER = 'user'
    PASSWORD = 'password'
    ACCOUNT = 'account'

    attr_accessor :append
    attr_accessor :delete
    attr_accessor :list
    attr_accessor :mkdir
    attr_accessor :read
    attr_accessor :rename
    attr_accessor :rmdir
    attr_accessor :write

    def initialize(temp_dir)
      @temp_dir = temp_dir
      @append = true
      @delete = true
      @list = true
      @mkdir = true
      @read = true
      @rename = true
      @rmdir = true
      @write = true
    end

    def authenticate(user, password, account)
      user == USER &&
        (password.nil? || password == PASSWORD) &&
        (account.nil? || account == ACCOUNT)
    end

    def file_system(user)
      TestServerFileSystem.new(@temp_dir,
                               :append => @append,
                               :delete => @delete,
                               :list => @list,
                               :mkdir => @mkdir,
                               :read => @read,
                               :rename => @rename,
                               :rmdir => @rmdir,
                               :write => @write)
    end

  end
end

class TestServer

  module ForcesAccessDenied

    def self.included(includer)
      includer.extend ClassMethods
    end

    module ClassMethods

      def return_false_on_force_access_denied(method_name)
        original_method = instance_method(method_name)
        define_method method_name do |*args|
          ftp_path = args.first
          return false if force_access_denied?(ftp_path)
          original_method.bind(self).call *args
        end
      end

    end

    def force_access_denied?(ftp_path)
      ftp_path =~ /forbidden/
    end

  end

end

class TestServer

  module ForcesFileSystemError

    def self.included(includer)
      includer.extend ClassMethods
    end

    module ClassMethods

      def raise_on_file_system_error(method_name)
        original_method = instance_method(method_name)
        define_method method_name do |*args|
          ftp_path = args.first
          if force_file_system_error?(ftp_path)
            raise Ftpd::PermanentFileSystemError, 'Unable to do it'
          end
          original_method.bind(self).call *args
        end
      end

      def return_true_on_file_system_error(method_name)
        original_method = instance_method(method_name)
        define_method method_name do |*args|
          ftp_path = args.first
          return true if force_file_system_error?(ftp_path)
          original_method.bind(self).call *args
        end
      end

    end

    def force_file_system_error?(ftp_path)
      ftp_path =~ /unable/
    end

  end
end

class TestServer
  class TestServerFileSystem

    # In order to test ftpd's ability to adapt itself to the driver's
    # signature, we create a new, anonymous instance of the file
    # system class for each test.  The option flags determine whether
    # or not to mix in certain behavior such as writing files, reading
    # files, etc.

    def self.new(data_dir, opts)
      Class.new do

        include ForcesAccessDenied
        include ForcesFileSystemError

        include Ftpd::DiskFileSystem::Base

        if opts[:append]
          include Ftpd::DiskFileSystem::Append
          raise_on_file_system_error :append
        end

        if opts[:delete]
          include Ftpd::DiskFileSystem::Delete
          raise_on_file_system_error :delete
        end

        if opts[:list]
          include Ftpd::DiskFileSystem::List
        end

        if opts[:mkdir]
          include Ftpd::DiskFileSystem::Mkdir
        end

        if opts[:read]
          include Ftpd::DiskFileSystem::Read
          raise_on_file_system_error :read
        end

        if opts[:rename]
          include Ftpd::DiskFileSystem::Rename
          raise_on_file_system_error :rename
        end

        if opts[:rmdir]
          include Ftpd::DiskFileSystem::Rmdir
        end

        if opts[:write]
          include Ftpd::DiskFileSystem::Write
          raise_on_file_system_error :write
        end

        def initialize(data_dir)
          set_data_dir data_dir
          translate_exception SystemCallError
        end

        return_false_on_force_access_denied :accessible?

        return_true_on_file_system_error :accessible?
        return_true_on_file_system_error :exists?
        return_true_on_file_system_error :directory?

      end.new(data_dir)
    end

  end
end

class TestServer

  extend Forwardable
  include FileUtils
  include Ftpd::InsecureCertificate
  include TestServerFiles

  def initialize
    @temp_dir = Ftpd::TempDir.make
    @debug_file = Tempfile.new('ftp-server-debug-output')
    @debug_file.close
    @driver = TestServerDriver.new(@temp_dir)
    @server = Ftpd::FtpServer.new(@driver)
    @server.certfile_path = insecure_certfile_path
    @server.debug_path = @debug_file.path
    @templates = TestFileTemplates.new
    self.debug = false
    self.tls = :off
  end

  def_delegator :@server, :'auth_level'
  def_delegator :@server, :'auth_level='
  def_delegator :@server, :'debug='
  def_delegator :@server, :'session_timeout='
  def_delegator :@server, :'tls='

  def_delegator :@driver, :'append='
  def_delegator :@driver, :'delete='
  def_delegator :@driver, :'list='
  def_delegator :@driver, :'mkdir='
  def_delegator :@driver, :'rmdir='
  def_delegator :@driver, :'read='
  def_delegator :@driver, :'rename='
  def_delegator :@driver, :'write='

  def start
    @server.start
  end

  def stop
    @server.stop
  end

  def debug_output
    IO.read(@debug_file.path)
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

  def account
    TestServerDriver::ACCOUNT
  end

  def port
    @server.bound_port
  end

  def template(path)
    @templates[File.basename(path)]
  end

  private

  def temp_dir
    @temp_dir
  end

end
