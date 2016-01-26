# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  # The login commands

  class CmdLogin < CommandHandler

    # @return [String] The user for the current login sequence

    attr_accessor :user

    # @return [String] The password for the current login sequence

    attr_accessor :password

    def initialize(*)
      super
      @user = nil
      @password = nil
    end

    #  * User Name (USER) command.

    def cmd_user(argument)
      syntax_error unless argument
      sequence_error if logged_in
      @user = argument
      if config.auth_level > AUTH_USER
        reply "331 Password required"
        expect 'pass'
      else
        login @user
      end
    end

    # The Password (PASS) command

    def cmd_pass(argument)
      syntax_error unless argument
      @password = argument
      if config.auth_level > AUTH_PASSWORD
        reply "332 Account required"
        expect 'acct'
      else
        login @user, @password
      end
    end

    # The Account (ACCT) command

    def cmd_acct(argument)
      syntax_error unless argument
      account = argument
      login @user, @password, account
    end

  end

end
