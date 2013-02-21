#!/usr/bin/env ruby

module Ftpd
  class FtpServer < TlsServer

    attr_accessor :debug_path
    attr_accessor :response_delay

    def initialize(opts = {})
      super
      @driver = opts[:driver]
      self.debug_path = '/dev/stdout'
      @response_delay = 0
    end

    def session(socket)
      Session.new(:socket => socket,
                  :driver => @driver,
                  :debug_path => debug_path,
                  :response_delay => response_delay,
                  :tls => @tls).run
    end

  end
end
