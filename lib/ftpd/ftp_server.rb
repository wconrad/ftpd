#!/usr/bin/env ruby

module Ftpd
  class FtpServer < TlsServer

    attr_accessor :debug_path
    attr_accessor :driver
    attr_accessor :implicit_tls
    attr_accessor :password
    attr_accessor :response_delay
    attr_accessor :user

    def initialize(opts = {})
      super
      self.user = 'user'
      self.password = 'password'
      self.debug_path = '/dev/stdout'
      @driver = MissingDriver.new
      @response_delay = 0
      @implicit_tls = false
    end

    def session(socket)
      Session.new(:socket => socket,
                  :driver => @driver,
                  :user => user,
                  :password => password,
                  :debug_path => debug_path,
                  :response_delay => response_delay,
                  :implicit_tls => @implicit_tls).run
    end

  end
end
