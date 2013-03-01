#!/usr/bin/env ruby

module Ftpd
  class FtpServer < TlsServer

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

    # Create a new FTP server.  The server won't start until the
    # #start method is called.
    #
    # @param driver A driver for the server's dynamic behavior such as
    #               authentication and file system access.
    #
    # The driver should expose these public methods:
    #
    #     # Return truthy if the user/password should be allowed to
    #     # log in.
    #     authenticate(user, password)
    #     
    #     # Return the file system to use for a user.  The file system
    #     # should expose the same public methods as
    #     # Ftpd::DiskFileSystem.
    #     def file_system(user)

    def initialize(driver)
      super()
      @driver = driver
      @debug_path = '/dev/stdout'
      @debug = false
      @response_delay = 0
    end

    private

    def session(socket)
      Session.new(:socket => socket,
                  :driver => @driver,
                  :debug => @debug,
                  :debug_path => debug_path,
                  :response_delay => response_delay,
                  :tls => @tls).run
    end

  end
end
