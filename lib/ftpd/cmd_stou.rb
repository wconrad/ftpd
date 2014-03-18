require_relative 'command_handler'

module Ftpd

  class CmdStou < CommandHandler

    def cmd_stou(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :write
        path = argument || 'ftpd'
        path = File.expand_path(path, name_prefix)
        path = unique_path(path)
        ensure_accessible path
        ensure_exists File.dirname(path)
        contents = receive_file(File.basename(path))
        file_system.write path, contents
        reply "226 Transfer complete"
      end
    end

  end

end
