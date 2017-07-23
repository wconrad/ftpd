# frozen_string_literal: true

require_relative 'tls_server'

module Ftpd
  class FtpServer < TlsServer

    extend Forwardable

    DEFAULT_SERVER_NAME = 'wconrad/ftpd'
    DEFAULT_SESSION_TIMEOUT = 300 # seconds

    # If true, allow the PORT command to specify privileged data ports
    # (those below 1024).  Defaults to false.  Setting this to true
    # makes it easier for an attacker to use the server to attack
    # another server.  See RFC 2577 section 3.
    #
    # Set this before calling #start.
    #
    # @return [Boolean]

    attr_accessor :allow_low_data_ports

    # The authentication level.  One of:
    #
    # * Ftpd::AUTH_USER
    # * Ftpd::AUTH_PASSWORD (default)
    # * Ftpd::AUTH_ACCOUNT
    #
    # @return [Integer] The authentication level

    attr_accessor :auth_level

    # The delay (in seconds) after a failed login.  Defaults to 0.
    # Setting this makes brute force password guessing less efficient
    # for the attacker.  RFC-2477 suggests a delay of 5 seconds.

    attr_accessor :failed_login_delay

    # The class for formatting for LIST output.  Defaults to
    # {Ftpd::ListFormat::Ls} (unix "ls -l" style).
    #
    # Set this before calling #start.
    # @return [class that quacks like Ftpd::ListFormat::Ls]

    attr_accessor :list_formatter

    # The logger.  Defaults to nil (no logging).
    #
    # Set this before calling #start.
    #
    # @return [Logger]

    attr_reader :log

    def log=(logger)
      @log = logger || NullLogger.new
    end

    # The maximum number of connections the server will allow.
    # Defaults to {ConnectionThrottle::DEFAULT_MAX_CONNECTIONS}.
    #
    # Set this before calling #start.
    #
    # @!attribute max_connections
    # @return [Integer]

    def_delegator :@connection_throttle, :'max_connections'
    def_delegator :@connection_throttle, :'max_connections='

    # The maximum number of failed login attempts before disconnecting
    # the user.  Defaults to nil (no maximum).  When set, this may
    # makes brute-force password guessing attack less efficient.
    #
    # Set this before calling #start.
    #
    # @return [Integer]

    attr_accessor :max_failed_logins

    # The maximum number of connections the server will allow from a
    # given IP.  Defaults to
    # {ConnectionThrottle::DEFAULT_MAX_CONNECTIONS_PER_IP}.
    #
    # Set this before calling #start.
    #
    # @!attribute max_connections_per_ip
    # @return [Integer]

    def_delegator :@connection_throttle, :'max_connections_per_ip'
    def_delegator :@connection_throttle, :'max_connections_per_ip='

    # The advertised public IP for passive mode connections.  This is
    # the IP that the client must use to make a connection back to the
    # server.  If nil, the IP of the bound interface is used.  When
    # the FTP server is behind a firewall, set this to firewall's
    # public IP and add the appropriate rule to the firewall to
    # forward that IP to the machine that ftpd is running on.
    #
    # Set this before calling #start.
    #
    # @return [nil, String]
    attr_accessor :nat_ip

    # The range of ports for passive mode connections.  If nil, then a
    # random etherial port is used.  Otherwise, a random port from
    # this range is used.
    #
    # Set this before calling #start.
    #
    # @return [nil, Range]
    attr_accessor :passive_ports

    # The number of seconds to delay before replying.  This is for
    # testing, when you need to test, for example, client timeouts.
    # Defaults to 0 (no delay).
    #
    # Set this before calling #start.
    #
    # @return [Numeric]

    attr_accessor :response_delay

    # The server's name, sent in a STAT reply.  Defaults to
    # {DEFAULT_SERVER_NAME}.
    #
    # Set this before calling #start.
    #
    # @return [String]

    attr_accessor :server_name

    # The server's version, sent in a STAT reply.  Defaults to
    # Release::VERSION.
    #
    # Set this before calling #start.
    #
    # @return [String]

    attr_accessor :server_version

    # The session timeout.  When a session is awaiting a command, if
    # one is not received in this many seconds, the session is
    # disconnected.  Defaults to {DEFAULT_SESSION_TIMEOUT}.  If nil,
    # then timeout is disabled.
    #
    # Set this before calling #start.
    #
    # @return [Numeric]

    attr_accessor :session_timeout

    # The exception handler. When there is an unknown exception,
    # server replies 451 and calls exception_handler. If nil,
    # then it's ignored.
    #
    # Set this before calling #start.
    #
    # @return [Proc]

    attr_accessor :exception_handler

    # Defines the exception_handler.

    def on_exception(&block)
      self.exception_handler = block
    end

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
      @response_delay = 0
      @list_formatter = ListFormat::Ls
      @auth_level = AUTH_PASSWORD
      @session_timeout = 300
      @server_name = DEFAULT_SERVER_NAME
      @server_version = Release::VERSION
      @allow_low_data_ports = false
      @failed_login_delay = 0
      @nat_ip = nil
      @passive_ports = nil
      self.log = nil
      @connection_tracker = ConnectionTracker.new
      @connection_throttle = ConnectionThrottle.new(@connection_tracker)
    end

    private

    def allow_session?(socket)
      @connection_throttle.allow?(socket)
    end

    def deny_session socket
      @connection_throttle.deny socket
    end

    def session(socket)
      @connection_tracker.track(socket) do
        run_session socket
      end
    end

    def run_session(socket)
      config = SessionConfig.new
      config.allow_low_data_ports = @allow_low_data_ports
      config.auth_level = @auth_level
      config.driver = @driver
      config.failed_login_delay = @failed_login_delay
      config.list_formatter = @list_formatter
      config.log = @log
      config.max_failed_logins = @max_failed_logins
      config.nat_ip = @nat_ip
      config.passive_ports = @passive_ports
      config.response_delay = response_delay
      config.server_name = @server_name
      config.server_version = @server_version
      config.session_timeout = @session_timeout
      config.tls = @tls
      config.exception_handler = exception_handler
      session = Session.new(config, socket)
      session.run
    end

  end
end
