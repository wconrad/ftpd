require_relative 'command_handler'

module Ftpd

  class CmdList < CommandHandler

    def cmd_list(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :dir
        ensure_file_system_supports :file_info
        path = list_path(argument)
        path = File.expand_path(path, name_prefix)
        transmit_file(list(path), 'A')
      end
    end

  end

end
