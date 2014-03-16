module Ftpd

  class CmdStor < CommandHandler

    def cmd_stor(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :write
        path = argument
        syntax_error unless path
        path = File.expand_path(path, name_prefix)
        ensure_accessible path
        ensure_exists File.dirname(path)
        contents = receive_file
        file_system.write path, contents
        reply "226 Transfer complete"
      end
    end

  end

end
