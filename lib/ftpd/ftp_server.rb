#!/usr/bin/env ruby

module Ftpd
  class FtpServer < TlsServer

    attr_accessor :debug_path
    attr_accessor :driver
    attr_reader :implicit_tls
    attr_accessor :response_delay

    def initialize(opts = {})
      super
      @implicit_tls = opts[:implicit_tls]
      self.debug_path = '/dev/stdout'
      @driver = MissingDriver.new
      @response_delay = 0
    end

    def session(socket)
      Session.new(:socket => socket,
                  :driver => @driver,
                  :debug_path => debug_path,
                  :response_delay => response_delay,
                  :implicit_tls => @implicit_tls).run
    end

  end
end
