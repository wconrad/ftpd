#!/usr/bin/env ruby

module Ftpd
  class FtpServer < TlsServer

    DEFAULT_SERVER_NAME = 'wconrad/ftpd'
    DEFAULT_SESSION_TIMEOUT = 300 # seconds

    # If truthy, emit debug information (such as replies received and
    # responses sent) to the file named by #debug_path.
    #
    # Change to this attribute only take effect for new sessions.

    attr_accessor :debug

    # The path to which to write debug information.  Defaults to
    # '/dev/stdout'
    #
    # Change to this attribute only take effect for new sessions.

    attr_accessor :debug_path

    # The number of seconds to delay before replying.  This is for
    # testing, when you need to test, for example, client timeouts.
    # Defaults to 0 (no delay).
    #
    # Change to this attribute only take effect for new sessions.

    attr_accessor :response_delay

    # The class for formatting for LIST output.  Defaults to
    # {Ftpd::ListFormat::Ls}.  Changes to this attribute only take
    # effect for new sessions.

    attr_accessor :list_formatter

    # @return [Integer] The authentication level
    # One of:
    # * Ftpd::AUTH_USER
    # * Ftpd::AUTH_PASSWORD (default)
    # * Ftpd::AUTH_ACCOUNT

    attr_accessor :auth_level

    # The session timeout.  When a session is awaiting a command, if
    # one is not received in this many seconds, the session is
    # disconnected.  Defaults to {DEFAULT_SESSION_TIMEOUT}.  If nil,
    # then timeout is disabled.
    # @return [Numeric]

    attr_accessor :session_timeout

    # The server's name, sent in a STAT reply.  Defaults to
    # {DEFAULT_SERVER_NAME}.

    attr_accessor :server_name

    # The server's version, sent in a STAT reply.  Defaults to the
    # contents of the VERSION file.

    attr_accessor :server_version

    # Create a new FTP server.  The server won't start until the
    # #start method is called.
    #
    # @param driver A driver for the server's dynamic behavior such as
    #               authentication and file system access.
    #
    # The driver should expose these public methods:
    # * {Example::Driver#authenticate authenticate}
    # * {Example::Driver#file_system file_system}

    def initialize(driver)
      super()
      @driver = driver
      @debug_path = '/dev/stdout'
      @debug = false
      @response_delay = 0
      @list_formatter = ListFormat::Ls
      @auth_level = AUTH_PASSWORD
      @session_timeout = 300
      @server_name = DEFAULT_SERVER_NAME
      @server_version = read_version_file
    end

    private

    def session(socket)
      Session.new(:socket => socket,
                  :driver => @driver,
                  :debug => @debug,
                  :debug_path => debug_path,
                  :list_formatter => @list_formatter,
                  :response_delay => response_delay,
                  :tls => @tls,
                  :auth_level => @auth_level,
                  :session_timeout => @session_timeout,
                  :server_name => @server_name,
                  :server_version => @server_version).run
    end

    def read_version_file
      File.open(version_file_path, 'r', &:read).strip
    end

    def version_file_path
      File.expand_path('../../VERSION', File.dirname(__FILE__))
    end

  end
end
