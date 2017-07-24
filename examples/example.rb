#!/usr/bin/env ruby

unless $:.include?(File.dirname(__FILE__) + '/../lib')
  $:.unshift(File.dirname(__FILE__) + '/../lib')
end

require 'ftpd'
require 'ipaddr'
require 'optparse'

module Example

  # Command-line option parser

  class Arguments

    attr_reader :account
    attr_reader :auth_level
    attr_reader :debug
    attr_reader :eplf
    attr_reader :interface
    attr_reader :nat_ip
    attr_reader :passive_ports
    attr_reader :password
    attr_reader :port
    attr_reader :read_only
    attr_reader :session_timeout
    attr_reader :tls
    attr_reader :user

    def initialize(argv)
      @interface = '127.0.0.1'
      @tls = :explicit
      @port = 0
      @auth_level = 'password'
      # When running on travisci, the LOGNAME environment variable is
      # not set, but we require it to be set.
      @user = ENV['LOGNAME'] || "test"
      @password = ''
      @account = ''
      @session_timeout = default_session_timeout
      @log = nil
      @nat_ip = nil
      @passive_ports = nil
      op = option_parser
      op.parse!(argv)
    rescue OptionParser::ParseError => e
      $stderr.puts e
      exit(1)
    end

    private

    def option_parser
      OptionParser.new do |op|
        op.on('-p', '--port N', Integer, 'Bind to a specific port') do |t|
          @port = t
        end
        op.on('-i', '--interface IP', 'Bind to a specific interface') do |t|
          @interface = t
        end
        op.on('--tls [TYPE]', [:off, :explicit, :implicit],
              'Select TLS support (off, explicit, implicit)',
              'default = off') do |t|
          @tls = t
        end
        op.on('--eplf', 'LIST uses EPLF format') do |t|
          @eplf = t
        end 
        op.on('--read-only', 'Prohibit put, delete, rmdir, etc.') do |t|
          @read_only = t
        end
        op.on('--auth [LEVEL]', [:user, :password, :account],
              'Set authorization level (user, password, account)',
              'default = password') do |t|
          @auth_level = t
        end
        op.on('-U', '--user NAME', 'User for authentication',
              'defaults to current user') do |t|
          @user = t
        end
        op.on('-P', '--password PW', 'Password for authentication',
              'defaults to empty string') do |t|
          @password = t
        end
        op.on('-A', '--account PW', 'Account for authentication',
              'defaults to empty string') do |t|
          @account = t
        end
        op.on('--timeout SEC', Integer, 'Session idle timeout',
              "defaults to #{default_session_timeout}") do |t|
          @session_timeout = t
        end
        op.on('-d', '--debug', 'Write server debug log to stdout') do |t|
          @debug = t
        end
        op.on('--nat-ip IP', 'Set advertised passive mode IP') do |t|
          @nat_ip = t
        end
        op.on('--ports MIN..MAX', 'Port numbers for passive mode sockets') do |v|
          @passive_ports = Range.new(*v.split(/\.\./).map(&:to_i))
        end
      end
    end

    def default_session_timeout
      Ftpd::FtpServer::DEFAULT_SESSION_TIMEOUT
    end

  end
end

module Example

  # The FTP server requires and instance of a _driver_ which can
  # authenticate users and create a file system drivers for a given
  # user.  You can use this as a template for creating your own
  # driver.

  class Driver

    # Your driver's initialize method can be anything you need.  Ftpd
    # does not create an instance of your driver.

    def initialize(user, password, account, data_dir, read_only)
      @user = user
      @password = password
      @account = account
      @data_dir = data_dir
      @read_only = read_only
    end

    # Return true if the user should be allowed to log in.
    # @param user [String]
    # @param password [String]
    # @param account [String]
    # @return [Boolean]
    #
    # Depending upon the server's auth_level, some of these parameters
    # may be nil.  A parameter with a nil value is not required for
    # authentication.  Here are the parameters that are non-nil for
    # each auth_level:
    # * :user (user)
    # * :password (user, password)
    # * :account (user, password, account)

    def authenticate(user, password, account)
      user == @user &&
        (password.nil? || password == @password) &&
        (account.nil? || account == @account)
    end

    # Return the file system to use for a user.
    # @param user [String]
    # @return A file system driver that quacks like {Ftpd::DiskFileSystem}

    def file_system(user)
      if @read_only
        Ftpd::ReadOnlyDiskFileSystem
      else
        Ftpd::DiskFileSystem
      end.new(@data_dir)
    end

  end
end

module Example
  class Main

    include Ftpd::InsecureCertificate

    def initialize(argv)
      @args = Arguments.new(argv)
      @data_dir = Ftpd::TempDir.make
      create_files
      @driver = Driver.new(user, password, account,
                           @data_dir, @args.read_only)
      @server = Ftpd::FtpServer.new(@driver)
      configure_server
      @server.start
      display_connection_info
      create_connection_script
    end

    def run
      wait_until_stopped
    end

    private

    def configure_server
      @server.interface = @args.interface
      @server.port = @args.port
      @server.tls = @args.tls
      @server.passive_ports = @args.passive_ports
      @server.certfile_path = insecure_certfile_path
      if @args.eplf
        @server.list_formatter = Ftpd::ListFormat::Eplf
      end
      @server.auth_level = auth_level
      @server.session_timeout = @args.session_timeout
      @server.log = make_log
      @server.nat_ip = @args.nat_ip
    end

    def auth_level
      Ftpd.const_get("AUTH_#{@args.auth_level.upcase}")
    end

    def create_files
      create_file 'README',
      "This file, and the directory it is in, will go away\n"
      "When this example exits.\n"
    end

    def create_file(path, contents)
      full_path = File.expand_path(path, @data_dir)
      FileUtils.mkdir_p File.dirname(full_path)
      File.open(full_path, 'w') do |file|
        file.write contents
      end
    end

    def display_connection_info
      puts "Interface: #{@server.interface}"
      puts "Port: #{@server.bound_port}"
      puts "User: #{user.inspect}"
      puts "Pass: #{password.inspect}" if auth_level >= Ftpd::AUTH_PASSWORD
      puts "Account: #{account.inspect}" if auth_level >= Ftpd::AUTH_ACCOUNT
      puts "TLS: #{@args.tls}"
      puts "Directory: #{@data_dir}"
      puts "URI: #{uri}"
      puts "PID: #{$$}"
    end

    def uri
      "ftp://#{connection_host}:#{@server.bound_port}"
    end

    def create_connection_script
      command_path = '/tmp/connect-to-example-ftp-server.sh'
      File.open(command_path, 'w') do |file|
        file.puts "#!/bin/bash"
        file.puts "ftp $FTP_ARGS #{connection_host} #{@server.bound_port}"
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

    def user
      @args.user
    end

    def password
      @args.password
    end

    def account
      @args.account
    end

    def make_log
      @args.debug && Logger.new($stdout)
    end

    def connection_host
      addr = IPAddr.new(@server.interface)
      if addr.ipv6?
        '::1'
      else
        '127.0.0.1'
      end
    end

  end
end

Example::Main.new(ARGV).run if $0 == __FILE__
