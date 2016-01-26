# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdAppe < CommandHandler

    def cmd_appe(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :append
        path = argument
        syntax_error unless path
        path = File.expand_path(path, name_prefix)
        ensure_accessible path
        receive_file do |data_socket|
          file_system.append path, data_socket
        end
        reply "226 Transfer complete"
      end
    end

  end

end
