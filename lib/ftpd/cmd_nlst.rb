require_relative 'command_handler'

module Ftpd

  class CmdNlst < CommandHandler

    def cmd_nlst(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :dir
        path = list_path(argument)
        path = File.expand_path(path, name_prefix)
        transmit_file(name_list(path), 'A')
      end
    end

  end

end
