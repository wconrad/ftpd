#!/usr/bin/env ruby

module Ftpd
  class FtpServer < TlsServer

    attr_accessor :debug_path
    attr_accessor :debug
    attr_accessor :response_delay

    def initialize(driver)
      super()
      @driver = driver
      @debug_path = '/dev/stdout'
      @debug = false
      @response_delay = 0
    end

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
