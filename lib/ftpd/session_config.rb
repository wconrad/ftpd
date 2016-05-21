# frozen_string_literal: true

module Ftpd

  # All of the configuration needed by a session

  class SessionConfig

    # If true, allow the PORT command to specify privileged data ports
    # (those below 1024).  Defaults to false.  Setting this to true
    # makes it easier for an attacker to use the server to attack
    # another server.  See RFC 2577 section 3.
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

    # A driver for the server's dynamic behavior such as
    # authentication and file system access.
    #
    # The driver should expose these public methods:
    # * {Example::Driver#authenticate authenticate}
    # * {Example::Driver#file_system file_system}

    attr_accessor :driver

    # The delay (in seconds) after a failed login.  Defaults to 0.
    # Setting this makes brute force password guessing less efficient
    # for the attacker.  RFC-2477 suggests a delay of 5 seconds.

    attr_accessor :failed_login_delay

    # The class for formatting for LIST output.
    #
    # @return [class that quacks like Ftpd::ListFormat::Ls]

    attr_accessor :list_formatter

    # The logger.
    #
    # @return [Logger]

    attr_accessor :log

    # The maximum number of failed login attempts before disconnecting
    # the user.  Defaults to nil (no maximum).  When set, this may
    # makes brute-force password guessing attack less efficient.
    #
    # @return [Integer]

    attr_accessor :max_failed_logins

    # The number of seconds to delay before replying.  This is for
    # testing, when you need to test, for example, client timeouts.
    # Defaults to 0 (no delay).
    #
    # @return [Numeric]

    attr_accessor :response_delay

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

    # The server's name, sent in a STAT reply.  Defaults to
    # {Ftpd::FtpServer::DEFAULT_SERVER_NAME}.
    #
    # @return [String]

    attr_accessor :server_name

    # The server's version, sent in a STAT reply.
    #
    # @return [String]

    attr_accessor :server_version

    # The session timeout.  When a session is awaiting a command, if
    # one is not received in this many seconds, the session is
    # disconnected.  If nil, then timeout is disabled.
    #
    # @return [Numeric]

    attr_accessor :session_timeout

    # Whether or not to do TLS, and which flavor.
    #
    # One of:
    # * :off
    # * :explicit
    # * :implicit
    #
    # @return [Symbol]

    attr_accessor :tls

    # The exception handler. When there is an unknown exception,
    # server replies 451 and calls exception_handler. If nil,
    # then it's ignored.
    #
    # @return [Proc]

    attr_accessor :exception_handler

  end

end
